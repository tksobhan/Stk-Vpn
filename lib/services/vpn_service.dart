import 'package:flutter_v2ray_client/flutter_v2ray.dart';

class VpnService {
  static final VpnService _instance = VpnService._internal();
  factory VpnService() => _instance;
  VpnService._internal();

  V2ray? _v2ray;
  bool _isConnected = false;
  bool _isInitialized = false;

  bool get isConnected => _isConnected;

  Future<void> initialize({
    String notificationIconResourceType = 'mipmap',
    String notificationIconResourceName = 'ic_launcher',
  }) async {
    if (_isInitialized) return;

    _v2ray = V2ray(
      onStatusChanged: (status) {
        // در صورت نیاز می‌توان وضعیت را پردازش کرد
        // اما فعلاً از _isConnected استفاده می‌کنیم
      },
    );

    await _v2ray!.initialize(
      notificationIconResourceType: notificationIconResourceType,
      notificationIconResourceName: notificationIconResourceName,
    );

    _isInitialized = true;
    print('✅ V2Ray مقداردهی اولیه شد');
  }

  Future<void> startVpn(String config) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _v2ray!.startV2Ray(
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
      await _v2ray?.stopV2Ray();
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

  Future<String?> getServerDelay(String config) async {
    try {
      final delay = await _v2ray?.getServerDelay(config: config);
      return delay != null ? '${delay}ms' : null;
    } catch (e) {
      return null;
    }
  }
}
