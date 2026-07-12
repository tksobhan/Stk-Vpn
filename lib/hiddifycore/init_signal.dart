import 'package:v2raystk/core/directories/directories_provider.dart';
import 'package:v2raystk/core/notification/in_app_notification_controller.dart';
import 'package:v2raystk/core/preferences/general_preferences.dart';
import 'package:v2raystk/v2raystkcore/v2raystk_core_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'init_signal.g.dart';

@riverpod
class CoreRestartSignal extends _$CoreRestartSignal {
  @override
  int build() => 0;

  void restart() => state++;
}
