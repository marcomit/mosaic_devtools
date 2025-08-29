import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mosaic/mosaic.dart';
import 'package:mosaic_devtools/inspector_card.dart';

class EventModule extends Module {
  EventModule() : super(name: 'inspector_event');

  @override
  Future<void> onInit() async {
    final card = InspectorCard(name: name);
    injector.inject('devtools/dashboard', ModularExtension(card.build));
  }

  @override
  Widget build(BuildContext context) {
    return EventInspectorView();
  }
}

class EventInspectorView extends StatefulWidget {
  const EventInspectorView({super.key});

  @override
  State<EventInspectorView> createState() => _EventInspectorViewState();
}

class _EventInspectorViewState extends State<EventInspectorView>
    with TickerProviderStateMixin {
  final List<EventMessage> _messages = [];
  final Map<String, EventListener> _activeSubscriptions = {};
  final Set<String> _discoveredChannels = {};

  final _channelController = TextEditingController();
  final _payloadController = TextEditingController();
  final _subscribeController = TextEditingController();
  bool _isRetained = false;
  bool _autoScroll = true;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  EventListener? _globalListener;

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

    // Start with a subtle fade-in
    _fadeController.forward();

    // Listen to all events for discovery
    _globalListener = events.on<dynamic>('#', _onEventDiscovered);
  }

  @override
  void dispose() {
    if (_globalListener != null) {
      events.deafen(_globalListener!);
    }
    for (final listener in _activeSubscriptions.values) {
      events.deafen(listener);
    }
    _channelController.dispose();
    _payloadController.dispose();
    _subscribeController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onEventDiscovered(EventContext<dynamic> context) {
    setState(() {
      _discoveredChannels.add(context.name);
    });
  }

  void _onSubscribedEvent(EventContext<dynamic> context) {
    setState(() {
      _messages.insert(
        0,
        EventMessage(
          channel: context.name,
          payload: context.data?.toString() ?? '∅',
          timestamp: DateTime.now(),
          retained: false,
        ),
      );

      if (_messages.length > 200) {
        _messages.removeLast();
      }
    });
  }

  void _subscribe(String channel) {
    if (channel.isEmpty || _activeSubscriptions.containsKey(channel)) return;

    HapticFeedback.lightImpact();
    final listener = events.on<dynamic>(channel, _onSubscribedEvent);

    setState(() {
      _activeSubscriptions[channel] = listener;
    });
  }

  void _unsubscribe(String channel) {
    final listener = _activeSubscriptions.remove(channel);
    if (listener != null) {
      HapticFeedback.lightImpact();
      events.deafen(listener);
      setState(() {});
    }
  }

  void _sendEvent() {
    final channel = _channelController.text.trim();
    final payload = _payloadController.text.trim();

    if (channel.isEmpty) return;

    HapticFeedback.selectionClick();

    if (payload.isEmpty) {
      events.emit(channel, null, _isRetained);
    } else {
      events.emit<String>(channel, payload, _isRetained);
    }

    _payloadController.clear();
  }

  @override
  Widget build(BuildContext context) {
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
              child: Column(
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
                                color: Colors.green.withOpacity(0.8),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Event Flow',
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

                        // Subscribe input
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: TextField(
                            controller: _subscribeController,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontFamily: 'SF Mono',
                            ),
                            decoration: InputDecoration(
                              hintText: 'Channel pattern (e.g., user/*)',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  _subscribe(_subscribeController.text.trim());
                                  _subscribeController.clear();
                                },
                                icon: Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.white.withOpacity(0.6),
                                  size: 20,
                                ),
                              ),
                            ),
                            onSubmitted: (value) {
                              _subscribe(value.trim());
                              _subscribeController.clear();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Active subscriptions
                  if (_activeSubscriptions.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Text(
                            'Active Subscriptions',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${_activeSubscriptions.length}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _activeSubscriptions.length,
                        itemBuilder: (context, index) {
                          final channel = _activeSubscriptions.keys.elementAt(
                            index,
                          );
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.02),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.05),
                              ),
                            ),
                            child: ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              title: Text(
                                channel,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontFamily: 'SF Mono',
                                ),
                              ),
                              trailing: IconButton(
                                onPressed: () => _unsubscribe(channel),
                                icon: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white.withOpacity(0.4),
                                ),
                              ),
                              onTap: () {
                                _channelController.text = channel;
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  // Discovered channels
                  if (_discoveredChannels.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Discovered Channels',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _discoveredChannels.length,
                        itemBuilder: (context, index) {
                          final channel = _discoveredChannels.elementAt(index);
                          final isSubscribed = _activeSubscriptions.containsKey(
                            channel,
                          );

                          return Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            child: InkWell(
                              onTap: () {
                                if (isSubscribed) {
                                  _unsubscribe(channel);
                                } else {
                                  _subscribe(channel);
                                }
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
                                      isSubscribed
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      size: 14,
                                      color: isSubscribed
                                          ? Colors.blue.withOpacity(0.8)
                                          : Colors.white.withOpacity(0.3),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        channel,
                                        style: TextStyle(
                                          color: isSubscribed
                                              ? Colors.white70
                                              : Colors.white.withOpacity(0.4),
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
                          );
                        },
                      ),
                    ),
                  ],
                ],
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
                          'Messages',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),

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

                        const SizedBox(width: 24),

                        // Clear button
                        TextButton.icon(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _messages.clear();
                            });
                          },
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
                  ),

                  // Messages
                  Expanded(
                    child: _messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.handshake,
                                  size: 48,
                                  color: Colors.white.withOpacity(0.1),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Waiting for events...',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.3),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Subscribe to channels to see messages here',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.2),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            reverse: _autoScroll,
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message = _autoScroll
                                  ? _messages[_messages.length - 1 - index]
                                  : _messages[index];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.02),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.05),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            border: Border.all(
                                              color: Colors.blue.withOpacity(
                                                0.3,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            message.channel,
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              fontSize: 12,
                                              fontFamily: 'SF Mono',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        if (message.retained)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.amber.withOpacity(
                                                0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'RETAINED',
                                              style: TextStyle(
                                                color: Colors.amber.shade300,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '${message.timestamp.hour.toString().padLeft(2, '0')}:'
                                          '${message.timestamp.minute.toString().padLeft(2, '0')}:'
                                          '${message.timestamp.second.toString().padLeft(2, '0')}',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.4,
                                            ),
                                            fontSize: 12,
                                            fontFamily: 'SF Mono',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    SelectableText(
                                      message.payload,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontFamily: 'SF Mono',
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),

                  // Zen Footer
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      border: Border(
                        top: BorderSide(color: Colors.white.withOpacity(0.05)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: TextField(
                              controller: _channelController,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'SF Mono',
                              ),
                              decoration: InputDecoration(
                                hintText: 'Channel',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: TextField(
                              controller: _payloadController,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'SF Mono',
                              ),
                              decoration: InputDecoration(
                                hintText: 'Payload',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                              ),
                              onSubmitted: (_) => _sendEvent(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Retained toggle
                        Row(
                          children: [
                            Text(
                              'Retained',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Switch.adaptive(
                              value: _isRetained,
                              onChanged: (value) {
                                setState(() {
                                  _isRetained = value;
                                });
                              },
                              activeColor: Colors.amber.withOpacity(0.8),
                            ),
                          ],
                        ),

                        const SizedBox(width: 16),

                        // Send button
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.withOpacity(0.8),
                                Colors.blue.withOpacity(0.6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _sendEvent,
                              borderRadius: BorderRadius.circular(12),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.send,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Send',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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

class EventMessage {
  final String channel;
  final String payload;
  final DateTime timestamp;
  final bool retained;

  EventMessage({
    required this.channel,
    required this.payload,
    required this.timestamp,
    required this.retained,
  });
}
