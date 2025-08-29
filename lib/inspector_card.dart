import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mosaic/mosaic.dart';

class InspectorCard extends StatefulWidget {
  final String name;
  final String? description;
  final IconData? icon;
  final Color? accentColor;
  final int priority;
  final VoidCallback? onTap;

  const InspectorCard({
    super.key,
    required this.name,
    this.description,
    this.icon,
    this.accentColor,
    this.priority = 0,
    this.onTap,
  });

  @override
  State<InspectorCard> createState() => _InspectorCardState();

  Widget build(BuildContext context) => this;
}

class _InspectorCardState extends State<InspectorCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  late Animation<double> _scaleAnimation;

  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _hoverAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  Color get _defaultAccentColor => _getAccentColorFromName();

  Color _getAccentColorFromName() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.cyan,
      Colors.pink,
      Colors.amber,
      Colors.teal,
    ];

    final hash = widget.name.hashCode;
    return colors[hash.abs() % colors.length];
  }

  IconData get _defaultIcon => _getIconFromName();

  IconData _getIconFromName() {
    final name = widget.name.toLowerCase();
    if (name.contains('event')) return Icons.radar;
    if (name.contains('module')) return Icons.view_module;
    if (name.contains('log')) return Icons.terminal;
    if (name.contains('network')) return Icons.wifi;
    if (name.contains('storage')) return Icons.storage;
    if (name.contains('performance')) return Icons.speed;
    if (name.contains('router')) return Icons.route;
    return Icons.developer_mode;
  }

  String get _displayName {
    return widget.name
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

  void _onTap() {
    HapticFeedback.lightImpact();

    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      // Default navigation behavior
      try {
        router.go(widget.name);
      } catch (e) {
        // Handle navigation error gracefully
        debugPrint('Failed to navigate to ${widget.name}: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.accentColor ?? _defaultAccentColor;
    final icon = widget.icon ?? _defaultIcon;

    return AnimatedBuilder(
      animation: _hoverAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) {
              setState(() => _isHovering = true);
              _hoverController.forward();
            },
            onExit: (_) {
              setState(() => _isHovering = false);
              _hoverController.reverse();
            },
            child: GestureDetector(
              onTap: _onTap,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(
                        0.03 + (_hoverAnimation.value * 0.02),
                      ),
                      Colors.white.withOpacity(
                        0.01 + (_hoverAnimation.value * 0.02),
                      ),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isHovering
                        ? accentColor.withOpacity(0.3)
                        : Colors.white.withOpacity(0.08),
                    width: _isHovering ? 1.5 : 1,
                  ),
                  boxShadow: _isHovering
                      ? [
                          BoxShadow(
                            color: accentColor.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 0,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  accentColor.withOpacity(0.8),
                                  accentColor.withOpacity(0.4),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Icon(icon, color: Colors.white, size: 18),
                          ),
                          const Spacer(),
                          AnimatedRotation(
                            turns: _hoverAnimation.value * 0.1,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white.withOpacity(
                                0.3 + (_hoverAnimation.value * 0.4),
                              ),
                              size: 14,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Title
                      Text(
                        _displayName,
                        style: TextStyle(
                          color: Colors.white.withOpacity(
                            0.9 + (_hoverAnimation.value * 0.1),
                          ),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Description
                      Text(
                        widget.description ?? _getDefaultDescription(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(
                            0.5 + (_hoverAnimation.value * 0.2),
                          ),
                          fontSize: 12,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 12),

                      // Status Indicator
                      Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: _getStatusColor(),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _getStatusColor().withOpacity(0.5),
                                  blurRadius: 3,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getStatusText(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getDefaultDescription() {
    final name = widget.name.toLowerCase();
    if (name.contains('event')) return 'Monitor event flow across modules';
    if (name.contains('module'))
      return 'Inspect module lifecycle & dependencies';
    if (name.contains('log')) return 'View and filter application logs';
    if (name.contains('network')) return 'Monitor network requests & responses';
    if (name.contains('storage')) return 'Inspect local storage & databases';
    if (name.contains('performance')) return 'Analyze performance metrics';
    if (name.contains('router')) return 'Debug navigation & routing state';
    return 'Inspect and debug app components';
  }

  Color _getStatusColor() {
    // In a real implementation, this would check if the module is loaded/active
    try {
      final isActive = moduleManager.activeModules.containsKey(widget.name);
      return isActive ? Colors.green : Colors.orange;
    } catch (e) {
      return Colors.grey;
    }
  }

  String _getStatusText() {
    try {
      final isActive = moduleManager.activeModules.containsKey(widget.name);
      return isActive ? 'Active' : 'Available';
    } catch (e) {
      return 'Unknown';
    }
  }
}
