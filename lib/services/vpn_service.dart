import 'package:flutter_v2ray_client/v2ray_client.dart';

class VpnService {
  static final VpnService _instance = VpnService._internal();
  factory VpnService() => _instance;
  VpnService._internal();

  final V2RayClient _client = V2RayClient.instance;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Future<void> startVpn(String config) async {
    try {
      await _client.start(
        config: config,
        remark: 'V2RAY stk',
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
      await _client.stop();
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

  Future<bool> isRunning() async {
    try {
      return await _client.isRunning();
    } catch (e) {
      return false;
    }
  }
}
