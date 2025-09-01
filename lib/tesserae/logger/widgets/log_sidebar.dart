import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mosaic/mosaic.dart';

class LogSidebar extends StatefulWidget {
  final List<String> availableTags;
  final Set<String> selectedTags;
  final Set<LogType> selectedLevels;
  final Function(String) onTagSelected;
  final Function(LogType) onLevelToggled;
  final Function(String) onSearchChanged;
  final String searchQuery;

  const LogSidebar({
    super.key,
    required this.availableTags,
    required this.selectedTags,
    required this.selectedLevels,
    required this.onTagSelected,
    required this.onLevelToggled,
    required this.onSearchChanged,
    required this.searchQuery,
  });

  @override
  State<LogSidebar> createState() => _LogSidebarState();
}

class _LogSidebarState extends State<LogSidebar> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getLevelColor(LogType level) {
    switch (level) {
      case LogType.debug:
        return Colors.grey;
      case LogType.info:
        return Colors.blue;
      case LogType.warning:
        return Colors.orange;
      case LogType.error:
        return Colors.red;
    }
  }

  IconData _getLevelIcon(LogType level) {
    switch (level) {
      case LogType.debug:
        return Icons.bug_report;
      case LogType.info:
        return Icons.info;
      case LogType.warning:
        return Icons.warning;
      case LogType.error:
        return Icons.error;
    }
  }

  void _toggleDispatcher(String dispatcherName, bool active) {
    HapticFeedback.lightImpact();
    logger.setDispatcher(dispatcherName, active);
    setState(() {}); // Refresh to show new state
  }

  Map<String, bool> _getDispatcherStates() {
    // Access internal dispatchers - this would need to be exposed in your logger
    // For now, we'll simulate common dispatchers
    return {
      'console': true, // Usually always active
      'file': logger.dispatchers.containsKey('file')
          ? logger.dispatchers['file']!.active
          : false,
      'network': logger.dispatchers.containsKey('network')
          ? logger.dispatchers['network']!.active
          : false,
      'debug': logger.dispatchers.containsKey('debug')
          ? logger.dispatchers['debug']!.active
          : false,
    };
  }

  @override
  Widget build(BuildContext context) {
    final dispatchers = _getDispatcherStates();

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
                      color: Colors.amber.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Log Stream',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Search input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontFamily: 'SF Mono',
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search logs...',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white.withValues(alpha: 0.4),
                      size: 20,
                    ),
                    suffixIcon: widget.searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              widget.onSearchChanged('');
                            },
                            icon: Icon(
                              Icons.clear,
                              color: Colors.white.withValues(alpha: 0.4),
                              size: 16,
                            ),
                          )
                        : null,
                  ),
                  onChanged: widget.onSearchChanged,
                ),
              ),
            ],
          ),
        ),

        // Dispatchers Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Dispatchers',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${dispatchers.values.where((active) => active).length}/${dispatchers.length}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...dispatchers.entries.map((entry) {
                final name = entry.key;
                final isActive = entry.value;
                final color = _getDispatcherColor(name);
                final icon = _getDispatcherIcon(name);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? color.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isActive
                          ? color.withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _toggleDispatcher(name, !isActive),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              icon,
                              color: isActive
                                  ? color
                                  : Colors.white.withValues(alpha: 0.4),
                              size: 16,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                name.toUpperCase(),
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'SF Mono',
                                ),
                              ),
                            ),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isActive ? color : Colors.grey,
                                shape: BoxShape.circle,
                                boxShadow: isActive
                                    ? [
                                        BoxShadow(
                                          color: color.withValues(alpha: 0.5),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Log Levels Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Log Levels',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${widget.selectedLevels.length}/4',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...LogType.values.map((level) {
                final isSelected = widget.selectedLevels.contains(level);
                final color = _getLevelColor(level);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? color.withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        widget.onLevelToggled(level);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getLevelIcon(level),
                              color: isSelected
                                  ? color
                                  : Colors.white.withValues(alpha: 0.4),
                              size: 16,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              level.name.toUpperCase(),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.6),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'SF Mono',
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              Icon(Icons.check, color: color, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Tags Section
        if (widget.availableTags.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  'Tags',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.selectedTags.length}/${widget.availableTags.length}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.availableTags.length,
              itemBuilder: (context, index) {
                final tag = widget.availableTags[index];
                final isSelected = widget.selectedTags.contains(tag);

                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        widget.onTagSelected(tag);
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              size: 14,
                              color: isSelected
                                  ? Colors.blue.withValues(alpha: 0.8)
                                  : Colors.white.withValues(alpha: 0.3),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                tag,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white70
                                      : Colors.white.withValues(alpha: 0.4),
                                  fontSize: 12,
                                  fontFamily: 'SF Mono',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
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
      ],
    );
  }

  Color _getDispatcherColor(String name) {
    switch (name.toLowerCase()) {
      case 'console':
        return Colors.green;
      case 'file':
        return Colors.blue;
      case 'network':
        return Colors.purple;
      case 'debug':
        return Colors.orange;
      default:
        return Colors.cyan;
    }
  }

  IconData _getDispatcherIcon(String name) {
    switch (name.toLowerCase()) {
      case 'console':
        return Icons.terminal;
      case 'file':
        return Icons.description;
      case 'network':
        return Icons.cloud_upload;
      case 'debug':
        return Icons.bug_report;
      default:
        return Icons.output;
    }
  }
}
