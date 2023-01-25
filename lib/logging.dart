import 'package:logger/logger.dart';
import 'package:one_for_twelve/app_config.dart';

void initLogging() {
  Logger.level = AppConfig.instance.minimumLogLevel;
  Log.instance.i('Logger initialized');
}

class Log {
  static Logger get instance {
    return Logger(
      filter: LevelLogFilter(AppConfig.instance.isRunningInEmulator),
      printer: SimplePrinter(colors: true),
    );
  }

  Log._();
}

class LevelLogFilter extends LogFilter {
  final bool _isRunningInEmulator;

  LevelLogFilter(this._isRunningInEmulator);

  @override
  bool shouldLog(LogEvent event) {
    return _isRunningInEmulator && (event.level.index >= Logger.level.index);
  }
}
