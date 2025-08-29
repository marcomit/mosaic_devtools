import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mosaic/mosaic.dart';
import 'route_info.dart';
import 'widgets/module_stack_panel.dart';
import 'widgets/page_stack_panel.dart';
import 'widgets/route_breadcrumb.dart';

class RouterInspectorView extends StatefulWidget {
  const RouterInspectorView({super.key});

  @override
  State<RouterInspectorView> createState() => _RouterInspectorViewState();
}

class _RouterInspectorViewState extends State<RouterInspectorView>
    with TickerProviderStateMixin, Admissible {
  String? _selectedModuleName;
  bool _autoRefresh = true;
  final List<RouteInfo> _routeHistory = [];

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _fadeController.forward();

    // Listen to route changes
    on<RouteTransitionContext>('router/change/*', _onRouteChanged);

    _loadInitialState();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _loadInitialState() {
    // Get current router state
    try {
      final currentModule = moduleManager.currentModule;
      if (currentModule != null) {
        _selectedModuleName = currentModule;
      }
    } catch (e) {
      // Handle case where no current module
    }
  }

  void _onRouteChanged(EventContext<RouteTransitionContext> context) {
    final transition = context.data;
    if (transition != null) {
      setState(() {
        _routeHistory.insert(
          0,
          RouteInfo(
            fromModule: transition.from?.name,
            toModule: transition.to.name,
            timestamp: transition.timestamp,
            params: transition.params,
          ),
        );

        // Keep only last 50 route changes
        if (_routeHistory.length > 50) {
          _routeHistory.removeLast();
        }

        _selectedModuleName = transition.to.name;
      });
    }
  }

  void _onModuleSelected(String moduleName) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedModuleName = moduleName;
    });
  }

  void _refresh() {
    HapticFeedback.lightImpact();
    setState(() {});
  }

  void _navigateToModule(String moduleName) {
    try {
      router.go(moduleName);
    } catch (e) {
      // Handle navigation error
    }
  }

  void _clearModuleStack(String moduleName) {
    try {
      final module = moduleManager.activeModules[moduleName];
      if (module != null) {
        module.clear();
        setState(() {});
      }
    } catch (e) {
      // Handle error
    }
  }

  void _popFromModule(String moduleName) {
    try {
      final module = moduleManager.activeModules[moduleName];
      if (module != null && module.hasStack) {
        module.pop();
        setState(() {});
      }
    } catch (e) {
      // Handle error
    }
  }

  RouteState _getCurrentRouteState() {
    try {
      final currentModuleName = moduleManager.currentModule;
      final moduleStack = router.history.map((entry) => entry.module).toList();

      Map<String, List<Widget>> pageStacks = {};
      for (final entry in moduleManager.activeModules.entries) {
        final moduleName = entry.key;
        final module = entry.value;
        pageStacks[moduleName] = module.stack.toList();
      }

      return RouteState(
        currentModule: currentModuleName,
        moduleStack: moduleStack,
        pageStacks: pageStacks,
        routeHistory: _routeHistory,
      );
    } catch (e) {
      return RouteState(
        currentModule: null,
        moduleStack: [],
        pageStacks: {},
        routeHistory: _routeHistory,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final routeState = _getCurrentRouteState();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Modern Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
              ),
              child: Row(
                children: [
                  // Back button
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.goBack();
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white.withOpacity(0.7),
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.8),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Router',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 24),

                  // Route breadcrumb
                  Expanded(
                    child: RouteBreadcrumb(
                      moduleStack: routeState.moduleStack,
                      currentModule: routeState.currentModule,
                      onModuleSelected: _onModuleSelected,
                    ),
                  ),

                  // Controls
                  Row(
                    children: [
                      // Auto-refresh toggle
                      Row(
                        children: [
                          Text(
                            'Auto-refresh',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Switch.adaptive(
                            value: _autoRefresh,
                            onChanged: (value) {
                              setState(() {
                                _autoRefresh = value;
                              });
                            },
                            activeColor: Colors.purple.withOpacity(0.8),
                          ),
                        ],
                      ),

                      const SizedBox(width: 16),

                      // Refresh button
                      TextButton.icon(
                        onPressed: _refresh,
                        icon: const Icon(
                          Icons.refresh,
                          size: 16,
                          color: Colors.white60,
                        ),
                        label: const Text(
                          'Refresh',
                          style: TextStyle(color: Colors.white60),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Row(
                children: [
                  // Module Stack Panel
                  Container(
                    width: 320,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1A1A1A),
                          const Color(0xFF0F0F0F),
                        ],
                      ),
                      border: Border(
                        right: BorderSide(
                          color: Colors.white.withOpacity(0.05),
                          width: 1,
                        ),
                      ),
                    ),
                    child: ModuleStackPanel(
                      routeState: routeState,
                      selectedModule: _selectedModuleName,
                      onModuleSelected: _onModuleSelected,
                      onNavigateToModule: _navigateToModule,
                    ),
                  ),

                  // Page Stack Panel
                  Expanded(
                    child: PageStackPanel(
                      routeState: routeState,
                      selectedModule: _selectedModuleName,
                      onClearStack: _clearModuleStack,
                      onPopFromStack: _popFromModule,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
