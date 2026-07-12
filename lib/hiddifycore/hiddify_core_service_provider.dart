import 'package:v2raystk/core/directories/directories_provider.dart';
import 'package:v2raystk/core/notification/in_app_notification_controller.dart';
import 'package:v2raystk/core/preferences/general_preferences.dart';
import 'package:v2raystk/v2raystkcore/v2raystk_core_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'v2raystk_core_service_provider.g.dart';

@Riverpod(keepAlive: true, dependencies: [AppDirectories, DebugModeNotifier, inAppNotificationController])
V2ray StkCoreService v2raystkCoreService(Ref ref) {
  return V2ray StkCoreService(ref);
}
