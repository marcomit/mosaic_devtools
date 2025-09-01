import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../route_info.dart';

class PageStackPanel extends StatelessWidget {
  final RouteState routeState;
  final String? selectedModule;
  final Function(String) onClearStack;
  final Function(String) onPopFromStack;

  const PageStackPanel({
    super.key,
    required this.routeState,
    required this.selectedModule,
    required this.onClearStack,
    required this.onPopFromStack,
  });

  @override
  Widget build(BuildContext context) {
    final currentStack = selectedModule != null
        ? routeState.pageStacks[selectedModule!] ?? []
        : <Widget>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
            ),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Page Stack',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      if (selectedModule != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _formatModuleName(selectedModule!),
                            style: TextStyle(
                              color: Colors.purple.shade300,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedModule != null
                        ? '${currentStack.length} pages in stack'
                        : 'Select a module to view its page stack',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (selectedModule != null && currentStack.isNotEmpty) ...[
                // Stack actions
                Row(
                  children: [
                    _buildActionButton(
                      icon: Icons.clear_all,
                      label: 'Clear',
                      color: Colors.red,
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        onClearStack(selectedModule!);
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.undo,
                      label: 'Pop',
                      color: Colors.orange,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onPopFromStack(selectedModule!);
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // Content
        Expanded(
          child: selectedModule == null
              ? _buildSelectModuleState()
              : currentStack.isEmpty
              ? _buildEmptyStackState()
              : _buildPageStack(currentStack),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color.withValues(alpha: 0.8)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectModuleState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.touch_app,
                  color: Colors.white.withValues(alpha: 0.4),
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Select a Module',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose a module from the left panel\nto inspect its page stack',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStackState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.layers_clear,
                  color: Colors.white.withValues(alpha: 0.4),
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Pages in Stack',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This module has no pages pushed\nonto its internal navigation stack',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageStack(List<Widget> stack) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: stack.length,
      itemBuilder: (context, index) {
        final pageIndex =
            stack.length - 1 - index; // Reverse order (top = newest)
        final page = stack[pageIndex];
        final isTop = index == 0;

        return Column(
          children: [
            _buildPageCard(page: page, stackIndex: pageIndex, isTop: isTop),
            if (index < stack.length - 1) _buildStackConnector(),
          ],
        );
      },
    );
  }

  Widget _buildPageCard({
    required Widget page,
    required int stackIndex,
    required bool isTop,
  }) {
    final pageType = page.runtimeType.toString();
    final key = page.key?.toString();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isTop
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.withValues(alpha: 0.15),
                  Colors.blue.withValues(alpha: 0.05),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.02),
                ],
              ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTop
              ? Colors.blue.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
          width: isTop ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isTop
                      ? Colors.blue.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    stackIndex.toString(),
                    style: TextStyle(
                      color: isTop
                          ? Colors.blue.withValues(alpha: 0.9)
                          : Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatPageType(pageType),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isTop)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'TOP',
                              style: TextStyle(
                                color: Colors.blue.shade200,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pageType,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontFamily: 'SF Mono',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Details
          if (key != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.key,
                    size: 12,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      key,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 10,
                        fontFamily: 'SF Mono',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Page info
          Row(
            children: [
              _buildPageProperty(
                icon: Icons.memory,
                label: 'Hash',
                value: page.hashCode.toString(),
              ),
              const SizedBox(width: 16),
              _buildPageProperty(
                icon: Icons.info_outline,
                label: 'Widget',
                value: _getWidgetInfo(page),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageProperty({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 12,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 10,
                fontFamily: 'SF Mono',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStackConnector() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const SizedBox(width: 15),
          Container(
            width: 2,
            height: 20,
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
          const SizedBox(width: 12),
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

  String _formatPageType(String pageType) {
    // Remove common Flutter widget suffixes and format nicely
    return pageType
        .replaceAll('StatefulWidget', '')
        .replaceAll('StatelessWidget', '')
        .replaceAll('Widget', '')
        .replaceAll('Page', '')
        .replaceAll('View', '')
        .replaceAll('Screen', '')
        .split(RegExp(r'(?=[A-Z])'))
        .where((part) => part.isNotEmpty)
        .join(' ')
        .trim();
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

  String _getWidgetInfo(Widget widget) {
    if (widget is StatefulWidget) {
      return 'Stateful';
    } else if (widget is StatelessWidget) {
      return 'Stateless';
    } else {
      return 'Unknown';
    }
  }
}
