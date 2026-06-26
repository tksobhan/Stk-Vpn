import 'package:flutter/services.dart';

class CoreController {
  static const MethodChannel _channel = MethodChannel('core_channel');

  static Future<String> startCore(String type, String config) async {
    try {
      final result = await _channel.invokeMethod('startCore', {
        'type': type,
        'config': config,
      });
      return result.toString();
    } on PlatformException catch (e) {
      return 'Error: ${e.message}';
    }
  }

  static Future<String> stopCore() async {
    try {
      final result = await _channel.invokeMethod('stopCore');
      return result.toString();
    } on PlatformException catch (e) {
      return 'Error: ${e.message}';
    }
  }

  static Future<String> switchCore(String type, String config) async {
    try {
      final result = await _channel.invokeMethod('switchCore', {
        'type': type,
        'config': config,
      });
      return result.toString();
    } on PlatformException catch (e) {
      return 'Error: ${e.message}';
    }
  }

  static Future<String> getStatus() async {
    try {
      final result = await _channel.invokeMethod('getStatus');
      return result.toString();
    } on PlatformException catch (e) {
      return 'Error: ${e.message}';
    }
  }
}
