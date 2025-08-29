import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../module_info.dart';

class ModuleSidebar extends StatelessWidget {
  final List<ModuleInfo> modules;
  final ModuleInfo? selectedModule;
  final Function(ModuleInfo) onModuleSelected;

  const ModuleSidebar({
    super.key,
    required this.modules,
    required this.selectedModule,
    required this.onModuleSelected,
  });

  @override
  Widget build(BuildContext context) {
    final activeCount = modules.where((m) => m.isActive).length;

    return Column(
      children: [
        // Sidebar Header
        Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Module System',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    '${modules.length} total',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '$activeCount active',
                    style: TextStyle(
                      color: Colors.green.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Module List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: modules.length,
            itemBuilder: (context, index) {
              final moduleInfo = modules[index];
              final isSelected = selectedModule?.name == moduleInfo.name;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.08)
                      : Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Colors.blue.withOpacity(0.3)
                        : Colors.white.withOpacity(0.05),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onModuleSelected(moduleInfo);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildStatusIndicator(moduleInfo),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  moduleInfo.name,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'SF Mono',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              _buildBadge(
                                moduleInfo.stateText,
                                moduleInfo.stateColor,
                              ),
                              if (moduleInfo.stackDepth > 0)
                                _buildBadge(
                                  '${moduleInfo.stackDepth} pages',
                                  Colors.purple,
                                ),
                              if (moduleInfo.dependencyCount > 0)
                                _buildBadge(
                                  '${moduleInfo.dependencyCount} deps',
                                  Colors.orange,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(ModuleInfo moduleInfo) {
    return Stack(
      children: [
        Container(
          child: Icon(
            moduleInfo.stateIcon,
            color: moduleInfo.stateColor,
            size: 20,
          ),
        ),
        if (moduleInfo.isCurrent)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.5),
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

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
