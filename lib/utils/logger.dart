import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

Logger logger = Logger(
  filter: _Filter(),
  printer: PrefixPrinter(
    PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 8,
        colors: false,
        printEmojis: false,
        printTime: true),
  ),
);

class _Filter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => !kReleaseMode;
}