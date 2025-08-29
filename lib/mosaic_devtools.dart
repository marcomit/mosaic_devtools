import 'package:flutter/material.dart';
import 'package:mosaic/mosaic.dart';
import 'package:mosaic_devtools/tesserae/devtools.dart';
import 'package:mosaic_devtools/tesserae/events/events.dart';
import 'package:mosaic_devtools/tesserae/logger/logger.dart';
import 'package:mosaic_devtools/tesserae/module/module.dart';
import 'package:mosaic_devtools/tesserae/router/router.dart';

enum DevtoolsPosition { topLeft, topRight, bottomLeft, bottomRight }

class MosaicDevtools extends StatefulWidget {
  const MosaicDevtools._({required this.child, required this.position});

  final Widget child;
  final DevtoolsPosition position;

  /// Wraps your app with floating devtools panel
  static Widget wrap({
    required Widget child,
    DevtoolsPosition position = DevtoolsPosition.bottomRight,
  }) {
    return MosaicDevtools._(position: position, child: child);
  }

  static Future<void> init() async {
    final devtools = DevToolsModule();
    await moduleManager.register(devtools);

    final eventModule = EventModule();
    eventModule.dependencies.add(devtools);
    await moduleManager.register(EventModule());

    final loggerModule = LoggerInspectorModule();
    loggerModule.dependencies.add(devtools);
    await moduleManager.register(loggerModule);

    final module = ModulesInspectorModule();
    module.dependencies.add(devtools);
    await moduleManager.register(module);

    final routerModule = RouterInspectorModule();
    routerModule.dependencies.add(devtools);
    await moduleManager.register(routerModule);
  }

  @override
  State<MosaicDevtools> createState() => _MosaicDevtoolsState();
}

class _MosaicDevtoolsState extends State<MosaicDevtools>
    with TickerProviderStateMixin {
  final bool _isDevtoolsOpen = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.elasticOut),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main app
        widget.child,

        // Floating devtools button
        Positioned(
          top:
              widget.position == DevtoolsPosition.topLeft ||
                  widget.position == DevtoolsPosition.topRight
              ? 50.0
              : null,
          bottom:
              widget.position == DevtoolsPosition.bottomLeft ||
                  widget.position == DevtoolsPosition.bottomRight
              ? 50.0
              : null,
          left:
              widget.position == DevtoolsPosition.topLeft ||
                  widget.position == DevtoolsPosition.bottomLeft
              ? 20.0
              : null,
          right:
              widget.position == DevtoolsPosition.topRight ||
                  widget.position == DevtoolsPosition.bottomRight
              ? 20.0
              : null,
          child: _buildFloatingButton(),
        ),
      ],
    );
  }

  Widget _buildFloatingButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isDevtoolsOpen ? 1.0 : _pulseAnimation.value,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(28),
            color: Colors.grey[900],
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: _isDevtoolsOpen
                      ? Colors.orange
                      : Colors.orange.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: IconButton(
                onPressed: () => router.go('devtools'),
                icon: Icon(
                  Icons.developer_mode,
                  color: _isDevtoolsOpen
                      ? Colors.orange
                      : Colors.orange.withOpacity(0.8),
                  size: 24,
                ),
                tooltip: 'Open Mosaic DevTools',
              ),
            ),
          ),
        );
      },
    );
  }
}
