import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mosaic/mosaic.dart';
import 'module_info.dart';
import 'widgets/module_sidebar.dart';
import 'widgets/module_details.dart';

class ModulesInspectorView extends StatefulWidget {
  const ModulesInspectorView({super.key});

  @override
  State<ModulesInspectorView> createState() => _ModulesInspectorViewState();
}

class _ModulesInspectorViewState extends State<ModulesInspectorView>
    with TickerProviderStateMixin {
  ModuleInfo? _selectedModule;
  bool _autoRefresh = true;

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
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onModuleSelected(ModuleInfo moduleInfo) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedModule = moduleInfo;
    });
  }

  void _refresh() {
    HapticFeedback.lightImpact();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final allModules = moduleManager.modules;
    final activeModules = moduleManager.activeModules;
    final currentModuleName = moduleManager.currentModule;

    // Convert to ModuleInfo list
    final moduleInfos = allModules.entries.map((entry) {
      final moduleName = entry.key;
      final module = entry.value;
      final isActive = activeModules.containsKey(moduleName);
      final isCurrent = currentModuleName == moduleName;

      return ModuleInfo(
        name: moduleName,
        module: module,
        isActive: isActive,
        isCurrent: isCurrent,
      );
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Row(
          children: [
            // Zen Sidebar
            Container(
              width: 340,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFF1A1A1A), const Color(0xFF0F0F0F)],
                ),
                border: Border(
                  right: BorderSide(
                    color: Colors.white.withOpacity(0.05),
                    width: 1,
                  ),
                ),
              ),
              child: ModuleSidebar(
                modules: moduleInfos,
                selectedModule: _selectedModule,
                onModuleSelected: _onModuleSelected,
              ),
            ),

            // Main Content
            Expanded(
              child: Column(
                children: [
                  // Modern Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.05),
                        ),
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
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
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

                        Text(
                          _selectedModule?.name ?? 'Module System',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),

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
                              activeColor: Colors.blue.withOpacity(0.8),
                            ),
                          ],
                        ),

                        const SizedBox(width: 24),

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
                  ),

                  // Content
                  Expanded(
                    child: _selectedModule == null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.view_module_outlined,
                                  size: 48,
                                  color: Colors.white.withOpacity(0.1),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Select a module',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.3),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Choose a module from the sidebar to inspect its details',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.2),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ModuleDetails(
                            moduleInfo: _selectedModule!,
                            onRefresh: _refresh,
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
