import 'package:flutter/material.dart';
import 'package:mosaic/mosaic.dart';

class ModuleInfo {
  final String name;
  final Module module;
  final bool isActive;
  final bool isCurrent;

  const ModuleInfo({
    required this.name,
    required this.module,
    required this.isActive,
    required this.isCurrent,
  });

  String get stateText {
    switch (module.state) {
      case ModuleLifecycleState.uninitialized:
        return 'UNINITIALIZED';
      case ModuleLifecycleState.initializing:
        return 'INITIALIZING';
      case ModuleLifecycleState.active:
        return 'ACTIVE';
      case ModuleLifecycleState.suspended:
        return 'SUSPENDED';
      case ModuleLifecycleState.disposing:
        return 'DISPOSING';
      case ModuleLifecycleState.disposed:
        return 'DISPOSED';
      case ModuleLifecycleState.error:
        return 'ERROR';
    }
  }

  Color get stateColor {
    switch (module.state) {
      case ModuleLifecycleState.active:
        return Colors.green;
      case ModuleLifecycleState.suspended:
        return Colors.orange;
      case ModuleLifecycleState.error:
        return Colors.red;
      case ModuleLifecycleState.initializing:
      case ModuleLifecycleState.disposing:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData get stateIcon {
    switch (module.state) {
      case ModuleLifecycleState.active:
        return Icons.play_circle_filled;
      case ModuleLifecycleState.suspended:
        return Icons.pause_circle_filled;
      case ModuleLifecycleState.error:
        return Icons.error;
      case ModuleLifecycleState.uninitialized:
        return Icons.radio_button_unchecked;
      default:
        return Icons.circle_outlined;
    }
  }

  int get stackDepth => module.stackDepth;
  bool get hasStack => module.hasStack;
  int get dependencyCount => module.di.instances.length;
  bool get hasError => module.hasError;
  Object? get lastError => module.lastError;
  bool get isFullScreen => module.fullScreen;
  List<Object> get dependencies => module.di.instances;
  Iterable<Widget> get stack => module.stack;
}
