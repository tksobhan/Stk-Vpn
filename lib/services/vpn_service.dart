import 'package:flutter_singbox_client/flutter_singbox_client.dart';
import 'dart:async';

class VpnService {
  static final VpnService _instance = VpnService._internal();
  factory VpnService() => _instance;
  VpnService._internal();

  final Singbox _singbox = Singbox();
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Future<void> initialize() async {
    // Singbox به مقداردهی اولیه خاصی نیاز ندارد
    print('✅ Sing-box مقداردهی اولیه شد');
  }

  Future<void> startVpn(String config) async {
    try {
      await _singbox.start(config);
      _isConnected = true;
      print('✅ Sing-box متصل شد');
    } catch (e) {
      print('❌ خطا در اتصال Sing-box: $e');
      _isConnected = false;
      rethrow;
    }
  }

  Future<void> stopVpn() async {
    try {
      await _singbox.stop();
      _isConnected = false;
      print('❌ Sing-box قطع شد');
    } catch (e) {
      print('❌ خطا در قطع Sing-box: $e');
      rethrow;
    }
  }

  Future<void> toggleVpn(String config) async {
    if (_isConnected) {
      await stopVpn();
    } else {
      await startVpn(config);
    }
  }

  Future<bool> isRunning() async {
    try {
      return await _singbox.isRunning();
    } catch (e) {
      return false;
    }
  }
}
