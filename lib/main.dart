import 'package:flutter/material.dart';
import 'package:flutter_v2ray_client/flutter_v2ray.dart';

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
  final V2ray _v2ray = V2ray(
    onStatusChanged: (status) {
      print('📡 V2Ray status: ${status.state}');
    },
  );

  bool _isConnected = false;
  bool _isInitializing = true;
  String _logMessage = '';

  static const String _tunConfig = '''
{
  "log": { "loglevel": "info" },
  "inbounds": [
    {
      "type": "tun",
      "tag": "tun-in",
      "address": ["172.19.0.1/30", "fdfe:dcba:9876:ffff::/64"],
      "mtu": 9000,
      "auto_route": true,
      "strict_route": true,
      "sniff": true,
      "sniff_override_destination": true,
      "platform": {
        "http_proxy": {
          "enabled": true,
          "server": "127.0.0.1",
          "port": 10808
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
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
    _initializeV2ray();
  }

  Future<void> _initializeV2ray() async {
    try {
      await _v2ray.initialize(
        notificationIconResourceType: "mipmap",
        notificationIconResourceName: "ic_launcher",
      );
      final hasPermission = await _v2ray.requestPermission();
      if (!hasPermission) {
        setState(() => _logMessage = '❌ مجوز VPN داده نشد');
      }
    } catch (e) {
      setState(() => _logMessage = '❌ خطا: $e');
    } finally {
      setState(() => _isInitializing = false);
    }
  }

  Future<void> _toggleConnection() async {
    if (_isInitializing) return;

    if (_isConnected) {
      await _v2ray.stopV2Ray();
      setState(() {
        _isConnected = false;
        _logMessage = '❌ قطع شد';
      });
    } else {
      try {
        await _v2ray.startV2Ray(
          remark: 'V2RAY stk',
          config: _tunConfig,
        );
        setState(() {
          _isConnected = true;
          _logMessage = '✅ وصل شد (اما ترافیک ممکن است هدایت نشود)';
        });
      } catch (e) {
        setState(() => _logMessage = '❌ خطا: $e');
      }
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
            const SizedBox(height: 10),
            Text(
              _logMessage,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
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
