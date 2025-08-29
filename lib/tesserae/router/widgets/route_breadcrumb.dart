import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RouteBreadcrumb extends StatelessWidget {
  final List<String> moduleStack;
  final String? currentModule;
  final Function(String) onModuleSelected;

  const RouteBreadcrumb({
    super.key,
    required this.moduleStack,
    required this.currentModule,
    required this.onModuleSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (moduleStack.isEmpty && currentModule == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.help_outline,
              color: Colors.white.withOpacity(0.4),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'No active route',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    // Build breadcrumb from module stack + current module
    final breadcrumbItems = <String>[];
    breadcrumbItems.addAll(moduleStack);

    if (currentModule != null && !breadcrumbItems.contains(currentModule)) {
      breadcrumbItems.add(currentModule!);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.route, color: Colors.purple.withOpacity(0.8), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: breadcrumbItems.indexed.map((item) {
                  final (index, moduleName) = item;
                  final isLast = index == breadcrumbItems.length - 1;
                  final isCurrent = moduleName == currentModule;

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (index > 0) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.white.withOpacity(0.3),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onModuleSelected(moduleName);
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? Colors.purple.withOpacity(0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: isCurrent
                                  ? Border.all(
                                      color: Colors.purple.withOpacity(0.4),
                                      width: 1,
                                    )
                                  : null,
                            ),
                            child: Text(
                              _formatModuleName(moduleName),
                              style: TextStyle(
                                color: isCurrent
                                    ? Colors.purple.shade300
                                    : isLast
                                    ? Colors.white.withOpacity(0.8)
                                    : Colors.white.withOpacity(0.5),
                                fontSize: 12,
                                fontWeight: isCurrent
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                fontFamily: 'SF Mono',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatModuleName(String moduleName) {
    // Remove common prefixes and format nicely
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
