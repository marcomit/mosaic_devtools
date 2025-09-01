import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mosaic/mosaic.dart';
import '../module_info.dart';

class ModuleDetails extends StatelessWidget {
  final ModuleInfo moduleInfo;
  final VoidCallback onRefresh;

  const ModuleDetails({
    super.key,
    required this.moduleInfo,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildModuleOverview(),
          const SizedBox(height: 24),
          _buildNavigationStack(),
          const SizedBox(height: 24),
          _buildDependencyContainer(),
          const SizedBox(height: 24),
          _buildModuleActions(),
        ],
      ),
    );
  }

  Widget _buildModuleOverview() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStatusIndicator(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      moduleInfo.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'SF Mono',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Full Screen: ${moduleInfo.isFullScreen ? 'Enabled' : 'Disabled'}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoGrid(),
          if (moduleInfo.hasError && moduleInfo.lastError != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade300,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Error Details',
                        style: TextStyle(
                          color: Colors.red.shade300,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    moduleInfo.lastError.toString(),
                    style: TextStyle(
                      color: Colors.red.shade200,
                      fontSize: 12,
                      fontFamily: 'SF Mono',
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Stack(
      children: [
        Icon(moduleInfo.stateIcon, color: moduleInfo.stateColor, size: 24),

        if (moduleInfo.isCurrent)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoGrid() {
    final items = [
      _InfoItem('State', moduleInfo.stateText, moduleInfo.stateColor),
      _InfoItem(
        'Active',
        moduleInfo.isActive ? 'Yes' : 'No',
        moduleInfo.isActive ? Colors.green : Colors.red,
      ),
      _InfoItem('Stack Depth', '${moduleInfo.stackDepth}', Colors.white70),
      _InfoItem(
        'Dependencies',
        '${moduleInfo.dependencyCount}',
        Colors.white70,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 12,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.value,
                style: TextStyle(
                  color: item.color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'SF Mono',
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNavigationStack() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.layers_outlined,
                color: Colors.purple.withValues(alpha: 0.8),
                size: 20,
              ),
              const SizedBox(width: 12),
              const Text(
                'Navigation Stack',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${moduleInfo.stackDepth} pages',
                  style: TextStyle(
                    color: Colors.purple.shade300,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (moduleInfo.hasStack) ...[
            const SizedBox(height: 20),
            ...moduleInfo.stack.indexed.map((item) {
              final (index, widget) = item;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          '$index',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.runtimeType.toString(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontFamily: 'SF Mono',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ] else ...[
            const SizedBox(height: 20),
            Center(
              child: Text(
                'No pages in stack',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDependencyContainer() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.memory,
                color: Colors.orange.withValues(alpha: 0.8),
                size: 20,
              ),
              const SizedBox(width: 12),
              const Text(
                'Dependency Injection',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${moduleInfo.dependencyCount} dependencies',
                  style: TextStyle(
                    color: Colors.orange.shade300,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (moduleInfo.dependencyCount > 0) ...[
            const SizedBox(height: 20),
            ...moduleInfo.dependencies.map((instance) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.extension,
                      color: Colors.orange.withValues(alpha: 0.8),
                      size: 16,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        instance.runtimeType.toString(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontFamily: 'SF Mono',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ] else ...[
            const SizedBox(height: 20),
            Center(
              child: Text(
                'No dependencies registered',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModuleActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings,
                color: Colors.blue.withValues(alpha: 0.8),
                size: 20,
              ),
              const SizedBox(width: 12),
              const Text(
                'Actions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (moduleInfo.module.state == ModuleLifecycleState.suspended)
                _buildActionButton(
                  'Resume',
                  Icons.play_arrow,
                  Colors.green,
                  () => _resumeModule(),
                ),
              if (moduleInfo.module.state == ModuleLifecycleState.active)
                _buildActionButton(
                  'Suspend',
                  Icons.pause,
                  Colors.orange,
                  () => _suspendModule(),
                ),
              if (moduleInfo.module.state == ModuleLifecycleState.error)
                _buildActionButton(
                  'Recover',
                  Icons.refresh,
                  Colors.blue,
                  () => _recoverModule(),
                ),
              if (moduleInfo.hasStack)
                _buildActionButton(
                  'Clear Stack',
                  Icons.clear_all,
                  Colors.red,
                  () => _clearStack(),
                ),
              _buildActionButton(
                'Navigate To',
                Icons.navigation,
                Colors.blue,
                () => _navigateToModule(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.8), color.withValues(alpha: 0.6)],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _resumeModule() async {
    try {
      await moduleInfo.module.resume();
      onRefresh();
    } catch (e) {
      // Handle error - could show snackbar or log
    }
  }

  Future<void> _suspendModule() async {
    try {
      await moduleInfo.module.suspend();
      onRefresh();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _recoverModule() async {
    try {
      await moduleInfo.module.recover();
      onRefresh();
    } catch (e) {
      // Handle error
    }
  }

  void _clearStack() {
    moduleInfo.module.clear();
    onRefresh();
  }

  void _navigateToModule() {
    try {
      router.go(moduleInfo.name);
    } catch (e) {
      // Handle error
    }
  }
}

class _InfoItem {
  final String label;
  final String value;
  final Color color;

  const _InfoItem(this.label, this.value, this.color);
}
