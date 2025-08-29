import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mosaic/mosaic.dart';
import 'log_entry.dart';
import 'widgets/log_sidebar.dart';
import 'widgets/log_content.dart';

class LoggerInspectorView extends StatefulWidget {
  const LoggerInspectorView({super.key});

  @override
  State<LoggerInspectorView> createState() => _LoggerInspectorViewState();
}

class _LoggerInspectorViewState extends State<LoggerInspectorView>
    with TickerProviderStateMixin {
  final List<LogEntry> _logs = [];
  final Set<String> _availableTags = {};
  final Set<String> _selectedTags = {};
  final Set<LogType> _selectedLevels = {
    LogType.debug,
    LogType.info,
    LogType.warning,
    LogType.error,
  };

  bool _autoScroll = true;
  bool _isPaused = false;
  String _searchQuery = '';

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Custom logger wrapper to capture logs
  LoggerWrapperCallback? _loggerWrapper;

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
    _setupLogCapture();
  }

  @override
  void dispose() {
    if (_loggerWrapper != null) {
      logger.removeWrapper();
    }
    _fadeController.dispose();
    super.dispose();
  }

  void _setupLogCapture() {
    _loggerWrapper = (String message, LogType type, List<String> tags) {
      if (!_isPaused) {
        _addLogEntry(message, type, tags);
      }
      return message; // Return unchanged message
    };

    logger.addWrapper(_loggerWrapper!);
  }

  void _addLogEntry(String message, LogType type, List<String> tags) {
    if (!mounted) return;

    setState(() {
      _logs.insert(
        0,
        LogEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          message: message,
          type: type,
          tags: tags,
          timestamp: DateTime.now(),
        ),
      );

      // Add new tags to available tags
      _availableTags.addAll(tags);

      // Keep only last 1000 logs to prevent memory issues
      if (_logs.length > 1000) {
        _logs.removeLast();
      }
    });
  }

  List<LogEntry> get _filteredLogs {
    return _logs.where((log) {
      // Level filter
      if (!_selectedLevels.contains(log.type)) return false;

      // Tag filter
      if (_selectedTags.isNotEmpty) {
        if (!log.tags.any((tag) => _selectedTags.contains(tag))) return false;
      }

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!log.message.toLowerCase().contains(query) &&
            !log.tags.any((tag) => tag.toLowerCase().contains(query))) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _onTagSelected(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  void _onLevelToggled(LogType level) {
    setState(() {
      if (_selectedLevels.contains(level)) {
        _selectedLevels.remove(level);
      } else {
        _selectedLevels.add(level);
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _clearLogs() {
    HapticFeedback.lightImpact();
    setState(() {
      _logs.clear();
    });
  }

  void _togglePause() {
    HapticFeedback.lightImpact();
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _exportLogs() {
    HapticFeedback.lightImpact();
    // Implementation for exporting logs
    // Could save to file or copy to clipboard
  }

  @override
  Widget build(BuildContext context) {
    final filteredLogs = _filteredLogs;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Row(
          children: [
            // Zen Sidebar
            Container(
              width: 320,
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
              child: LogSidebar(
                availableTags: _availableTags.toList()..sort(),
                selectedTags: _selectedTags,
                selectedLevels: _selectedLevels,
                onTagSelected: _onTagSelected,
                onLevelToggled: _onLevelToggled,
                onSearchChanged: _onSearchChanged,
                searchQuery: _searchQuery,
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

                        const Text(
                          'Logger',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.5,
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Log stats
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${filteredLogs.length} / ${_logs.length}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Controls
                        Row(
                          children: [
                            // Pause/Resume
                            TextButton.icon(
                              onPressed: _togglePause,
                              icon: Icon(
                                _isPaused ? Icons.play_arrow : Icons.pause,
                                size: 16,
                                color: _isPaused ? Colors.green : Colors.orange,
                              ),
                              label: Text(
                                _isPaused ? 'Resume' : 'Pause',
                                style: TextStyle(
                                  color: _isPaused
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Auto-scroll toggle
                            Row(
                              children: [
                                Text(
                                  'Auto-scroll',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Switch.adaptive(
                                  value: _autoScroll,
                                  onChanged: (value) {
                                    setState(() {
                                      _autoScroll = value;
                                    });
                                  },
                                  activeColor: Colors.blue.withOpacity(0.8),
                                ),
                              ],
                            ),

                            const SizedBox(width: 16),

                            // Export button
                            TextButton.icon(
                              onPressed: _exportLogs,
                              icon: const Icon(
                                Icons.download,
                                size: 16,
                                color: Colors.white60,
                              ),
                              label: const Text(
                                'Export',
                                style: TextStyle(color: Colors.white60),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Clear button
                            TextButton.icon(
                              onPressed: _clearLogs,
                              icon: const Icon(
                                Icons.clear_all,
                                size: 16,
                                color: Colors.white60,
                              ),
                              label: const Text(
                                'Clear',
                                style: TextStyle(color: Colors.white60),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Log Content
                  Expanded(
                    child: LogContent(
                      logs: filteredLogs,
                      autoScroll: _autoScroll,
                      isPaused: _isPaused,
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
