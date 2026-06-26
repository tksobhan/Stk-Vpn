import 'package:flutter/material.dart';
import 'package:v2ray_stk/core/controller.dart';
import 'package:v2ray_stk/services/config_service.dart';
import 'dart:convert';
import 'dart:async';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String status = 'IDLE';
  String coreType = 'singbox';
  String? activeConfig;

  List<Map<String, String>> configs = [];

  bool _isLoading = false;
  String _logs = '';
  String _traffic = '0 KB/s / 0 KB/s';

  StreamSubscription? _logSub;
  StreamSubscription? _trafficSub;

  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _subController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    _listen();
  }

  void _load() async {
    configs = await ConfigService.loadConfigs();
    activeConfig = await ConfigService.loadActiveConfig();
    if (mounted) setState(() {});
  }

  void _listen() {
    _logSub = CoreController.getLogs().listen((log) {
      if (!mounted) return;
      setState(() => _logs = log);
    });

    _trafficSub = CoreController.getTraffic().listen((t) {
      if (!mounted) return;
      setState(() => _traffic = t);
    });
  }

  Future<void> _connect() async {
    if (_isLoading) return;
    if (activeConfig == null) return;

    setState(() => _isLoading = true);

    try {
      final res = await CoreController.startCore(coreType, activeConfig!);

      if (!mounted) return;

      if (res == "Started") {
        setState(() => status = "CONNECTED");
      } else {
        setState(() => status = "ERROR");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _disconnect() async {
    await CoreController.stopCore();
    if (mounted) setState(() => status = "DISCONNECTED");
  }

  @override
  void dispose() {
    _logSub?.cancel();
    _trafficSub?.cancel();
    _linkController.dispose();
    _subController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("STK VPN PRO")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Status: $status"),
            Text("Traffic: $_traffic"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _connect,
              child: const Text("CONNECT"),
            ),
            ElevatedButton(
              onPressed: _disconnect,
              child: const Text("DISCONNECT"),
            ),
          ],
        ),
      ),
    );
  }
}
