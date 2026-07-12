import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:ffi/ffi.dart';
import 'package:grpc/grpc.dart';
import 'package:v2raystk/core/model/directories.dart';
import 'package:v2raystk/gen/v2raystk_core_generated_bindings.dart';
import 'package:v2raystk/v2raystkcore/core_interface/core_interface.dart';
import 'package:v2raystk/v2raystkcore/core_interface/mtls_channel_cred.dart';
import 'package:v2raystk/v2raystkcore/generated/v2/hcore/hcore.pb.dart';
import 'package:v2raystk/v2raystkcore/generated/v2/hcore/hcore_service.pbgrpc.dart';
import 'package:v2raystk/v2raystkcore/generated/v2/hello/hello.pb.dart';
import 'package:v2raystk/v2raystkcore/generated/v2/hello/hello_service.pbgrpc.dart';
import 'package:v2raystk/utils/custom_loggers.dart';

import 'package:loggy/loggy.dart';

import 'package:path/path.dart' as p;

final _logger = Loggy('V2ray StkCoreFFI');
typedef StopFunc = Pointer<Utf8> Function();
typedef StopFuncDart = Pointer<Utf8> Function();

class CoreInterfaceDesktop extends CoreInterface with InfraLogger {
  static final V2ray StkCoreNativeLibrary _box = _gen();

  static V2ray StkCoreNativeLibrary _gen() {
    String fullPath = "";
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      fullPath = "v2raystk-core";
    }
    if (Platform.isWindows) {
      fullPath = p.join(fullPath, "v2raystk-core.dll");
    } else if (Platform.isMacOS) {
      fullPath = p.join(fullPath, "v2raystk-core.dylib");
    } else {
      fullPath = p.join(fullPath, "v2raystk-core.so");
    }

    _logger.debug('v2raystk-core native libs path: "$fullPath"');
    final lib = DynamicLibrary.open(fullPath);
    // final stopFunc = lib.lookup<NativeFunction<StopFunc>>('stop').asFunction<StopFunc>();
    // final errPtr2 = stopFunc();
    // final err = errPtr2.cast<Utf8>().toDartString();

    return V2ray StkCoreNativeLibrary(lib);
  }

  Future<bool> isMusl() async {
    try {
      final result = await Process.run('ldd', ['--version']);
      return result.stdout.toString().toLowerCase().contains('musl');
    } catch (_) {
      return false;
    }
  }

  final port = 17078;
  static String generateRandomPassword(int length) {
    const characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(length, (_) => characters[random.nextInt(characters.length)]).join();
  }

  static final String secret = generateRandomPassword(100);

  @override
  Future<String> setup(Directories directories, bool debug, int mode) async {
    // Generate a random password for the grpc service
    // final errPtr2 = _box.stop();
    // final err = errPtr2.cast<Utf8>().toDartString();
    // throw Exception('stop: $err');
    const channelOption = ChannelCredentials.insecure();
    final helloClient = HelloClient(
      ClientChannel(
        '127.0.0.1',
        port: port,
        options: const ChannelOptions(credentials: channelOption),
      ),
    );

    try {
      await helloClient.sayHello(HelloRequest(name: "test"));
      loggy.info("core is already started!");
    } catch (e) {
      //core is not started yet

      final errPtr = _box.setup(
        directories.baseDir.path.toNativeUtf8().cast(),
        directories.workingDir.path.toNativeUtf8().cast(),
        directories.tempDir.path.toNativeUtf8().cast(),
        SetupMode.GRPC_NORMAL_INSECURE.value,
        "127.0.0.1:$port".toNativeUtf8().cast(),
        secret.toNativeUtf8().cast(),
        0,
        debug ? 1 : 0,
      );
      final err = errPtr.cast<Utf8>().toDartString();

      if (err.isNotEmpty) {
        return err;
      }
      final res = await helloClient.sayHello(HelloRequest(name: "test"));
      loggy.info(res.toString());
    }
    bgClient = fgClient = CoreClient(
      ClientChannel(
        'localhost',
        port: port,
        options: const ChannelOptions(
          credentials: ChannelCredentials.insecure(),
          // credentials: ChannelCredentials.secure(
          //   password: secret,
          //   onBadCertificate: (certificate, host) => true,
          // ),
        ),
      ),
    );

    return "";
  }

  @override
  Future<bool> restart(String path, String name) async {
    return false;
  }

  @override
  Future<bool> stop() async {
    return false;
  }
}
