import 'package:flutter/material.dart';

class RouteInfo {
  final String? fromModule;
  final String toModule;
  final DateTime timestamp;
  final dynamic params;

  const RouteInfo({
    this.fromModule,
    required this.toModule,
    required this.timestamp,
    this.params,
  });

  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else {
      return '${timestamp.hour.toString().padLeft(2, '0')}:'
          '${timestamp.minute.toString().padLeft(2, '0')}:'
          '${timestamp.second.toString().padLeft(2, '0')}';
    }
  }

  String get transitionDescription {
    if (fromModule == null) {
      return 'Initial → $toModule';
    }
    return '$fromModule → $toModule';
  }
}

class RouteState {
  final String? currentModule;
  final List<String> moduleStack;
  final Map<String, List<Widget>> pageStacks;
  final List<RouteInfo> routeHistory;

  const RouteState({
    this.currentModule,
    required this.moduleStack,
    required this.pageStacks,
    required this.routeHistory,
  });

  int get totalPages {
    return pageStacks.values.fold(0, (sum, stack) => sum + stack.length);
  }

  List<String> get activeModules {
    return pageStacks.keys.where((moduleName) {
      return pageStacks[moduleName]?.isNotEmpty ?? false;
    }).toList();
  }

  Widget? getCurrentPage() {
    if (currentModule == null) return null;

    final currentStack = pageStacks[currentModule];
    if (currentStack == null || currentStack.isEmpty) return null;

    return currentStack.last;
  }

  String get currentPageType {
    final currentPage = getCurrentPage();
    return currentPage?.runtimeType.toString() ?? 'No page';
  }
}
