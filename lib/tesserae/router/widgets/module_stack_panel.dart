import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../route_info.dart';

class ModuleStackPanel extends StatelessWidget {
  final RouteState routeState;
  final String? selectedModule;
  final Function(String) onModuleSelected;
  final Function(String) onNavigateToModule;

  const ModuleStackPanel({
    super.key,
    required this.routeState,
    required this.selectedModule,
    required this.onModuleSelected,
    required this.onNavigateToModule,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Module Stack',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${routeState.moduleStack.length} modules in stack',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        // Module Stack
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Current module indicator
                if (routeState.currentModule != null) ...[
                  _buildCurrentModuleCard(),
                  const SizedBox(height: 16),
                ],

                // Module stack
                if (routeState.moduleStack.isNotEmpty) ...[
                  ...routeState.moduleStack.reversed.indexed.map((item) {
                    final (index, moduleName) = item;
                    final stackIndex =
                        routeState.moduleStack.length - 1 - index;
                    return Column(
                      children: [
                        _buildModuleCard(
                          moduleName: moduleName,
                          stackIndex: stackIndex,
                          isInStack: true,
                        ),
                        if (index < routeState.moduleStack.length - 1)
                          _buildStackConnector(),
                      ],
                    );
                  }),
                ] else ...[
                  _buildEmptyState(),
                ],

                // Recent route history
                const SizedBox(height: 24),
                _buildRouteHistory(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentModuleCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.withValues(alpha: 0.2),
            Colors.purple.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.purple.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'CURRENT',
                  style: TextStyle(
                    color: Colors.purple.shade200,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.radio_button_checked,
                color: Colors.purple.withValues(alpha: 0.8),
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _formatModuleName(routeState.currentModule!),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            routeState.currentModule!,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
              fontFamily: 'SF Mono',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildPageCount(routeState.currentModule!),
              const Spacer(),
              _buildNavigateButton(routeState.currentModule!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard({
    required String moduleName,
    required int stackIndex,
    required bool isInStack,
  }) {
    final isSelected = selectedModule == moduleName;
    final hasPages = (routeState.pageStacks[moduleName]?.length ?? 0) > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onModuleSelected(moduleName);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        stackIndex.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatModuleName(moduleName),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          moduleName,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 10,
                            fontFamily: 'SF Mono',
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasPages)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildPageCount(moduleName),
                  const Spacer(),
                  _buildNavigateButton(moduleName),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageCount(String moduleName) {
    final pageCount = routeState.pageStacks[moduleName]?.length ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: pageCount > 0
            ? Colors.green.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.layers,
            size: 12,
            color: pageCount > 0
                ? Colors.green.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 4),
          Text(
            pageCount.toString(),
            style: TextStyle(
              color: pageCount > 0
                  ? Colors.green.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.5),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigateButton(String moduleName) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onNavigateToModule(moduleName);
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.launch,
            size: 12,
            color: Colors.blue.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }

  Widget _buildStackConnector() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 11),
          Container(
            width: 2,
            height: 16,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.3),
                  Colors.white.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.layers_clear,
            color: Colors.white.withValues(alpha: 0.3),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'No modules in stack',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Navigate between modules to see the stack',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRouteHistory() {
    if (routeState.routeHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Recent Transitions',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...routeState.routeHistory.take(5).map((route) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        route.transitionDescription,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      route.formattedTime,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 10,
                        fontFamily: 'SF Mono',
                      ),
                    ),
                  ],
                ),
                if (route.params != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Params: ${route.params}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 10,
                      fontFamily: 'SF Mono',
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  String _formatModuleName(String moduleName) {
    return moduleName
        .replaceAll('inspector_', '')
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}
