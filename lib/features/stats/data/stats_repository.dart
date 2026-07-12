import 'package:fpdart/fpdart.dart';
import 'package:v2raystk/core/utils/exception_handler.dart';
import 'package:v2raystk/features/stats/model/stats_failure.dart';
import 'package:v2raystk/v2raystkcore/generated/v2/hcore/hcore.pb.dart';
import 'package:v2raystk/v2raystkcore/v2raystk_core_service.dart';
import 'package:v2raystk/utils/custom_loggers.dart';

abstract interface class StatsRepository {
  Stream<Either<StatsFailure, SystemInfo>> watchStats();
}

class StatsRepositoryImpl with ExceptionHandler, InfraLogger implements StatsRepository {
  StatsRepositoryImpl({required this.singbox});

  final V2ray StkCoreService singbox;

  @override
  Stream<Either<StatsFailure, SystemInfo>> watchStats() {
    return singbox.watchStats().handleExceptions(StatsUnexpectedFailure.new);
  }
}
