# V2RAY STK VPN

یک برنامه VPN کلاینت برای Flutter که از sing-box و v2ray استفاده می‌کند.

## ویژگی‌ها

- 🚀 کانکشن و قطع سریع VPN
- 📊 نمایش ترافیک لحظه‌ای
- ⚙️ تنظیمات پیشرفته
- 🔔 اطلاع‌رسانی‌های فوری
- 💾 ذخیره کانفیگ‌های مختلف
- 🔒 رمزگذاری داده‌ها

## محیط

- **Flutter**: >=3.7.2
- **Dart**: >=3.7.2
- **پلتفرم‌های پشتیبانی‌شده**: Android, iOS, Linux, macOS, Windows

## وابستگی‌ها

- `flutter_v2ray_plus`: ^1.0.0 - درایور VPN
- `shared_preferences`: ^2.1.2 - ذخیره تنظیمات
- `flutter_local_notifications`: ^17.2.4 - اطلاع‌رسانی‌ها

## نصب و راه‌اندازی

```bash
# نصب وابستگی‌ها
flutter pub get

# اجرا
flutter run
```

## ساختار پروژه

```
lib/
  ├── main.dart              # نقطه شروع برنامه
  ├── singbox_ffi.dart       # FFI برای sing-box
  ├── services/              # سرویس‌های تجاری
  │   ├── vpn_service.dart
  │   ├── config_service.dart
  │   ├── notification_service.dart
  │   └── preferences_service.dart
  ├── ui/                    # رابط کاربری
  │   └── dashboard.dart     # صفحه اصلی
  ├── core/                  # هسته برنامه
  │   ├── controller.dart
  │   └── core_supervisor.dart
  └── src/                   # کودهای کمکی
```

## اصلاح‌های انجام‌شده

- ✅ حل Merge Conflict در `main.dart`
- ✅ بهبود معالجه Null Safety
- ✅ افزودن پشتیبانی Linux
- ✅ بهبود مدیریت خطاها
- ✅ افزودن README کامل

## نکات مهم

### AndroidManifest.xml
اطمینان دهید که `android:foregroundServiceType="dataSync"` استفاده شود (نه `vpn`).

### FFI Library
برای اجرای صحیح، `libsingbox.so` باید در دستگاه موجود باشد.

## لایسنس

MIT
