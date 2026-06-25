import 'dart:async';

class VpnService {
  static final VpnService _instance = VpnService._internal();
  factory VpnService() => _instance;
  VpnService._internal();

  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Future<void> startVpn(String config) async {
    try {
      // شبیه‌سازی اتصال با تأخیر
      await Future.delayed(const Duration(seconds: 2));
      _isConnected = true;
      print('✅ VPN متصل شد (شبیه‌سازی)');
    } catch (e) {
      print('❌ خطا در اتصال VPN: $e');
      _isConnected = false;
      rethrow;
    }
  }

  Future<void> stopVpn() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _isConnected = false;
      print('❌ VPN قطع شد (شبیه‌سازی)');
    } catch (e) {
      print('❌ خطا در قطع VPN: $e');
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
}
