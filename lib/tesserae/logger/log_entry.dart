import 'package:flutter/material.dart';
import 'package:mosaic/mosaic.dart';

class LogEntry {
  final String id;
  final String message;
  final LogType type;
  final List<String> tags;
  final DateTime timestamp;

  const LogEntry({
    required this.id,
    required this.message,
    required this.type,
    required this.tags,
    required this.timestamp,
  });

  Color get levelColor {
    switch (type) {
      case LogType.debug:
        return Colors.grey;
      case LogType.info:
        return Colors.blue;
      case LogType.warning:
        return Colors.orange;
      case LogType.error:
        return Colors.red;
    }
  }

  IconData get levelIcon {
    switch (type) {
      case LogType.debug:
        return Icons.bug_report;
      case LogType.info:
        return Icons.info;
      case LogType.warning:
        return Icons.warning;
      case LogType.error:
        return Icons.error;
    }
  }

  String get levelText {
    switch (type) {
      case LogType.debug:
        return 'DEBUG';
      case LogType.info:
        return 'INFO';
      case LogType.warning:
        return 'WARN';
      case LogType.error:
        return 'ERROR';
    }
  }

  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${timestamp.hour.toString().padLeft(2, '0')}:'
          '${timestamp.minute.toString().padLeft(2, '0')}:'
          '${timestamp.second.toString().padLeft(2, '0')}';
    }
  }

  String get preciseTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}.'
        '${timestamp.millisecond.toString().padLeft(3, '0')}';
  }
}
