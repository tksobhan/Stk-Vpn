import 'package:flutter_v2ray_client/flutter_v2ray.dart';

class VpnService {
  static final VpnService _instance = VpnService._internal();
  factory VpnService() => _instance;
  VpnService._internal();

  V2ray? _v2ray;
  bool _isConnected = false;
  bool _isInitialized = false;

  bool get isConnected => _isConnected;

  // مقداردهی اولیه V2Ray
  Future<void> initialize({
    String notificationIconResourceType = 'mipmap',
    String notificationIconResourceName = 'ic_launcher',
  }) async {
    if (_isInitialized) return;

    _v2ray = V2ray(
      onStatusChanged: (status) {
        // وضعیت اتصال را بروزرسانی می‌کند
        _isConnected = status.state == V2RayStatus.connected;
        print('V2Ray status: ${status.state}');
      },
    );

    await _v2ray!.initialize(
      notificationIconResourceType: notificationIconResourceType,
      notificationIconResourceName: notificationIconResourceName,
    );

    _isInitialized = true;
    print('✅ V2Ray مقداردهی اولیه شد');
  }

  // شروع VPN با کانفیگ JSON
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

  // قطع VPN
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

  // تغییر وضعیت
  Future<void> toggleVpn(String config) async {
    if (_isConnected) {
      await stopVpn();
    } else {
      await startVpn(config);
    }
  }

  // دریافت تأخیر سرور
  Future<String?> getServerDelay(String config) async {
    try {
      final delay = await _v2ray?.getServerDelay(config: config);
      return delay != null ? '${delay}ms' : null;
    } catch (e) {
      return null;
    }
  }

  // بررسی اینکه آیا سرویس در حال اجراست
  Future<bool> isVpnRunning() async {
    try {
      return await _v2ray?.isVpnRunning() ?? false;
    } catch (e) {
      return false;
    }
  }

  // دریافت وضعیت فعلی
  Future<V2RayStatus?> getStatus() async {
    try {
      return await _v2ray?.getStatus();
    } catch (e) {
      return null;
    }
  }

  // پاکسازی منابع
  void dispose() {
    _v2ray?.dispose();
    _isInitialized = false;
  }
}
