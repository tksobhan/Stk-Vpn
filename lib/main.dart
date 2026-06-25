import 'package:flutter/material.dart';
import 'package:singbox_mm/singbox_mm.dart';

void main() => runApp(const MyApp());

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
  final SingboxMM _singbox = SingboxMM();
  bool _isConnected = false;
  bool _isInitializing = true;

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
      "type": "freedom",
      "tag": "direct"
    }
  ],
  "route": {
    "rules": [
      {
        "outbound": "direct",
        "network": ["tcp", "udp"]
      }
    ]
  }
}
''';

  @override
  void initState() {
    super.initState();
    _initializeSingbox();
  }

  Future<void> _initializeSingbox() async {
    try {
      await _singbox.initialize();
    } catch (e) {
      print('❌ خطا در مقداردهی اولیه: $e');
    } finally {
      setState(() => _isInitializing = false);
    }
  }

  Future<void> _toggleConnection() async {
    if (_isInitializing) return;

    if (_isConnected) {
      await _singbox.stop();
      setState(() => _isConnected = false);
    } else {
      await _singbox.start(_tunConfig);
      setState(() => _isConnected = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('V2RAY stk')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isConnected ? Icons.vpn_lock : Icons.vpn_key,
              size: 80,
              color: _isConnected ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              _isConnected ? '✅ وصل شده' : '❌ قطع است',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _isConnected ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _toggleConnection,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text(
                _isConnected ? 'قطع اتصال' : 'اتصال',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
