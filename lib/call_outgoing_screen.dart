import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// CallOutgoingScreen
// - Avatar, name, "Calling..." text
// - Large circular buttons: Mute, Speaker, End Call
// - Modern centered layout

class CallOutgoingScreen extends ConsumerStatefulWidget {
  const CallOutgoingScreen({
    super.key,
    required this.name,
    this.avatarTag = 'avatar-hero',
  });

  final String name;
  final String avatarTag;

  // Route suggestion: '/call_outgoing'
  @override
  ConsumerState<CallOutgoingScreen> createState() => _CallOutgoingScreenState();
}

class _CallOutgoingScreenState extends ConsumerState<CallOutgoingScreen> {
  bool _muted = false;
  bool _speaker = false;

  void _toggleMute() => setState(() => _muted = !_muted);
  void _toggleSpeaker() => setState(() => _speaker = !_speaker);
  void _endCall() {
    // Placeholder: end call behavior
    Navigator.of(context).maybePop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Call ended (placeholder)')));
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
    bool active = false,
  }) {
    final bg = active
        ? (color ?? Theme.of(context).colorScheme.primary)
        : Theme.of(context).colorScheme.surfaceContainerHighest;
    final fg = active
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.onSurface;
    return Column(
      children: [
        Material(
          color: bg,
          shape: const CircleBorder(),
          elevation: 4,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Icon(icon, size: 28, color: fg),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: widget.avatarTag,
                  child: CircleAvatar(
                    radius: 56,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: Text(
                      widget.name.isNotEmpty ? widget.name[0] : '?',
                      style: const TextStyle(fontSize: 36),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Calling...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 28),

                // Buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _actionButton(
                      icon: _muted ? Icons.mic_off : Icons.mic,
                      label: 'Mute',
                      onPressed: _toggleMute,
                      active: _muted,
                    ),
                    _actionButton(
                      icon: _speaker ? Icons.volume_up : Icons.volume_off,
                      label: 'Speaker',
                      onPressed: _toggleSpeaker,
                      active: _speaker,
                    ),
                    Column(
                      children: [
                        Material(
                          color: Colors.redAccent,
                          shape: const CircleBorder(),
                          elevation: 6,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _endCall,
                            child: const Padding(
                              padding: EdgeInsets.all(22.0),
                              child: Icon(
                                Icons.call_end,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'End',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
