import 'package:flutter_singbox_client/flutter_singbox_client.dart';

class VpnService {
  static final VpnService _instance = VpnService._internal();
  factory VpnService() => _instance;
  VpnService._internal();

  final Singbox _singbox = Singbox();
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  // شروع VPN با کانفیگ (فعلاً شبیه‌سازی)
  Future<void> startVpn(String config) async {
    try {
      // در آینده: await _singbox.start(config);
      // فعلاً فقط شبیه‌سازی
      await Future.delayed(const Duration(seconds: 1));
      _isConnected = true;
      print('VPN متصل شد');
    } catch (e) {
      print('خطا در اتصال VPN: $e');
      _isConnected = false;
      rethrow;
    }
  }

  // قطع VPN
  Future<void> stopVpn() async {
    try {
      // await _singbox.stop();
      await Future.delayed(const Duration(milliseconds: 500));
      _isConnected = false;
      print('VPN قطع شد');
    } catch (e) {
      print('خطا در قطع VPN: $e');
      rethrow;
    }
  }

  // تغییر وضعیت (اتصال/قطع)
  Future<void> toggleVpn(String config) async {
    if (_isConnected) {
      await stopVpn();
    } else {
      await startVpn(config);
    }
  }
}
