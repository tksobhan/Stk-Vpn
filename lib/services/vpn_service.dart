import 'package:flutter_v2ray/flutter_v2ray.dart';

class VpnService {
  static final VpnService _instance = VpnService._internal();
  factory VpnService() => _instance;
  VpnService._internal();

  final V2Ray _v2ray = V2Ray();
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Future<void> startVpn(String config) async {
    try {
      await _v2ray.startV2Ray(
        remark: 'V2RAY stk',
        config: config,
        useSystemProxy: false,
      );
      _isConnected = true;
      print('✅ V2Ray متصل شد');
    } catch (e) {
      print('❌ خطا در اتصال V2Ray: $e');
      _isConnected = false;
      rethrow;
    }
  }

  Future<void> stopVpn() async {
    try {
      await _v2ray.stopV2Ray();
      _isConnected = false;
      print('❌ V2Ray قطع شد');
    } catch (e) {
      print('❌ خطا در قطع V2Ray: $e');
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
