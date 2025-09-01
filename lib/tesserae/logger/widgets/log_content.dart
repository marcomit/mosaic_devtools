import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../log_entry.dart';

class LogContent extends StatefulWidget {
  final List<LogEntry> logs;
  final bool autoScroll;
  final bool isPaused;

  const LogContent({
    super.key,
    required this.logs,
    required this.autoScroll,
    required this.isPaused,
  });

  @override
  State<LogContent> createState() => _LogContentState();
}

class _LogContentState extends State<LogContent> {
  final ScrollController _scrollController = ScrollController();
  LogEntry? _selectedLog;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(LogContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Auto-scroll to bottom when new logs arrive
    if (widget.autoScroll && widget.logs.length > oldWidget.logs.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _copyLogMessage(LogEntry log) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: log.message));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Log message copied to clipboard'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green.withValues(alpha: 0.8),
      ),
    );
  }

  void _copyFullLog(LogEntry log) {
    HapticFeedback.lightImpact();
    final fullLog =
        '''
Time: ${log.preciseTime}
Level: ${log.levelText}
Tags: ${log.tags.join(', ')}
Message: ${log.message}
''';

    Clipboard.setData(ClipboardData(text: fullLog));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Full log entry copied to clipboard'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blue.withValues(alpha: 0.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.logs.isEmpty) {
      return _buildEmptyState();
    }

    return Row(
      children: [
        // Log list
        Expanded(
          flex: _selectedLog == null ? 1 : 2,
          child: ListView.builder(
            controller: _scrollController,
            reverse: widget.autoScroll,
            padding: const EdgeInsets.all(16),
            itemCount: widget.logs.length,
            itemBuilder: (context, index) {
              final log = widget.autoScroll
                  ? widget.logs[widget.logs.length - 1 - index]
                  : widget.logs[index];

              return _buildLogItem(log);
            },
          ),
        ),

        // Log details panel
        if (_selectedLog != null) ...[
          Container(width: 1, color: Colors.white.withValues(alpha: 0.05)),
          Expanded(flex: 1, child: _buildLogDetails(_selectedLog!)),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.isPaused ? Icons.pause_circle_outline : Icons.terminal,
            size: 48,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(
            widget.isPaused ? 'Logging paused' : 'No logs yet',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.isPaused
                ? 'Resume logging to continue capturing entries'
                : 'Start an action to see logs appear here',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.2),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(LogEntry log) {
    final isSelected = _selectedLog == log;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedLog = isSelected ? null : log;
        });
      },
      onLongPress: () => _copyLogMessage(log),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.05) : null,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time
            Text(
              '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 12),
            // Message
            Expanded(
              child: Text(
                log.message,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogDetails(LogEntry log) {
    return Container(
      color: Colors.black.withValues(alpha: 0.2),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Log Details",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 12),
          SelectableText(
            "Time: ${log.preciseTime}",
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
          ),
          SelectableText(
            "Level: ${log.levelText}",
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
          ),
          SelectableText(
            "Tags: ${log.tags.join(', ')}",
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 8),
          SelectableText(
            "Message:\n${log.message}",
            style: TextStyle(color: Colors.white),
          ),
          const Spacer(),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _copyLogMessage(log),
                icon: const Icon(Icons.copy),
                label: const Text("Copy message"),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _copyFullLog(log),
                icon: const Icon(Icons.description),
                label: const Text("Copy full"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
