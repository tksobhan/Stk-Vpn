import 'package:flutter/material.dart';
import 'package:v2ray_stk/core/controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String status = 'IDLE';
  String coreType = 'singbox';
  String config = '{}';

  Future<void> _connect() async {
    final result = await CoreController.startCore(coreType, config);
    setState(() => status = 'CONNECTED');
    print(result);
  }

  Future<void> _disconnect() async {
    final result = await CoreController.stopCore();
    setState(() => status = 'DISCONNECTED');
    print(result);
  }

  @override
  Widget build(BuildContext context) {
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
            Text(
              'وضعیت: $status',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _connect,
              child: const Text('اتصال'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _disconnect,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('قطع اتصال'),
            ),
          ],
        ),
      ),
    );
  }
}
