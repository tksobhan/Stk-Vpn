import 'dart:async';
import 'package:flutter/material.dart';
import 'singbox_ffi.dart';

void main() => runApp(const MyApp());

// ============================================================
// Engine Interface
// ============================================================
abstract class Engine {
  Future<void> start(String config);
  Future<void> stop();
  bool get isRunning;
  Stream<String> get logs;
}

// ============================================================
// SingBoxEngine (با FFI)
// ============================================================
class SingBoxEngine implements Engine {
  bool _isRunning = false;
  final StreamController<String> _logController = StreamController.broadcast();
  final SingboxFFI _ffi = SingboxFFI();

  @override
  bool get isRunning => _isRunning;

  @override
  Stream<String> get logs => _logController.stream;

  @override
  Future<void> start(String config) async {
    _addLog('🚀 شروع sing-box...');
    try {
      _ffi.loadLibrary();
      final result = await Future(() => _ffi.run(config));
      if (result == 0) {
        _isRunning = true;
        _addLog('✅ sing-box با موفقیت اجرا شد');
      } else {
        _addLog('❌ خطا در اجرا: کد خطا $result');
      }
    } catch (e) {
      _addLog('❌ خطا: $e');
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    _addLog('🛑 توقف sing-box...');
    try {
      await Future(() => _ffi.stop());
      _isRunning = false;
      _addLog('✅ sing-box متوقف شد');
    } catch (e) {
      _addLog('❌ خطا در توقف: $e');
      rethrow;
    }
  }

  void _addLog(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final formatted = '[$timestamp] $message';
    _logController.add(formatted);
    print(formatted);
  }

  void dispose() {
    _logController.close();
  }
}

// ============================================================
// EngineManager
// ============================================================
class EngineManager {
  Engine _currentEngine;

  EngineManager({required Engine engine}) : _currentEngine = engine;

  Engine get current => _currentEngine;

  Future<void> start(String config) async => await _currentEngine.start(config);
  Future<void> stop() async => await _currentEngine.stop();
  bool get isRunning => _currentEngine.isRunning;
  Stream<String> get logs => _currentEngine.logs;
}

// ============================================================
// UI
// ============================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'V2RAY stk',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late EngineManager _manager;
  bool _isInitializing = true;
  String _logMessage = '';
  final List<String> _logs = [];

  static const String _tunConfig = '''
{
  "log": { "level": "info" },
  "inbounds": [
    {
      "type": "tun",
      "tag": "tun-in",
      "address": ["172.19.0.1/30"],
      "mtu": 9000,
      "auto_route": true,
      "strict_route": true,
      "sniff": true,
      "sniff_override_destination": true
    }
  ],
  "outbounds": [
    {
      "type": "vless",
      "tag": "proxy",
      "settings": {
        "vnext": [
          {
            "address": "104.18.218.4",
            "port": 443,
            "users": [
              {
                "id": "ffa993c6-f992-b7d0-5933-ab0400000000",
                "encryption": "none",
                "flow": ""
              }
            ]
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "tlsSettings": {
          "serverName": "sparkling-wildflower-ebec.stk48.workers.dev",
          "fingerprint": "chrome",
          "allowInsecure": false
        },
        "wsSettings": {
          "path": "/Myself",
          "headers": {
            "Host": "sparkling-wildflower-ebec.stk48.workers.dev"
          }
        }
      }
    }
  ],
  "route": {
    "rules": [
      {
        "outbound": "proxy",
        "network": ["tcp", "udp"]
      }
    ]
  }
}
''';

  @override
  void initState() {
    super.initState();
    _initializeEngine();
  }

  Future<void> _initializeEngine() async {
    final engine = SingBoxEngine();
    _manager = EngineManager(engine: engine);
    _manager.logs.listen((log) {
      setState(() {
        _logs.add(log);
        if (_logs.length > 20) _logs.removeAt(0);
        _logMessage = log;
      });
    });
    setState(() => _isInitializing = false);
  }

  Future<void> _toggleConnection() async {
    if (_isInitializing) return;

    if (_manager.isRunning) {
      await _manager.stop();
      setState(() => _logMessage = '❌ قطع شد');
    } else {
      await _manager.start(_tunConfig);
      setState(() => _logMessage = '✅ وصل شد (تست FFI)');
    }
  }

  @override
  void dispose() {
    if (_manager.current is SingBoxEngine) {
      (_manager.current as SingBoxEngine).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('V2RAY stk'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _manager.isRunning ? Icons.vpn_lock : Icons.vpn_key,
              size: 80,
              color: _manager.isRunning ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              _manager.isRunning ? '✅ وصل شده' : '❌ قطع است',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _manager.isRunning ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _logs.isEmpty ? 'منتظر شروع...' : _logs.last,
                style: const TextStyle(fontSize: 12, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _toggleConnection,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text(
                _manager.isRunning ? 'قطع اتصال' : 'اتصال',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
