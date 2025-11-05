import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// CallOngoingScreen
// - Waveform animation using CustomPainter
// - Call timer (mm:ss)
// - Floating circular buttons: Mute, Speaker, Hangup

class CallOngoingScreen extends ConsumerStatefulWidget {
  const CallOngoingScreen({
    super.key,
    this.callerName = '',
    this.avatarTag = 'avatar-hero',
  });

  final String callerName;
  final String avatarTag;

  @override
  ConsumerState<CallOngoingScreen> createState() => _CallOngoingScreenState();
}

class _CallOngoingScreenState extends ConsumerState<CallOngoingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;
  late final Stopwatch _stopwatch;
  Timer? _timer;

  bool _muted = false;
  bool _speaker = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _stopwatch = Stopwatch()..start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _waveController.dispose();
    super.dispose();
  }

  void _toggleMute() => setState(() => _muted = !_muted);
  void _toggleSpeaker() => setState(() => _speaker = !_speaker);

  void _hangup() {
    // Placeholder hangup behavior
    Navigator.of(context).maybePop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Call ended (placeholder)')));
  }

  String get _elapsed {
    final seconds = _stopwatch.elapsed.inSeconds;
    final mm = (seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (seconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Subtle background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer.withAlpha(
                      (0.2 * 255).round(),
                    ),
                    Theme.of(context).colorScheme.surface,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Center content: caller + waveform + timer
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.callerName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18.0),
                    child: Text(
                      widget.callerName,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),

                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _WaveformPainter(
                          progress: _waveController.value,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 18),
                Text(
                  _elapsed,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'On call',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                  ),
                ),
              ],
            ),

            // Floating controls at bottom center
            Positioned(
              left: 0,
              right: 0,
              bottom: 28,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute
                  _buildControl(
                    icon: _muted ? Icons.mic_off : Icons.mic,
                    label: _muted ? 'Muted' : 'Mute',
                    color: _muted
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    onTap: _toggleMute,
                  ),

                  // Hangup (primary large)
                  Material(
                    color: Colors.red.shade600,
                    shape: const CircleBorder(),
                    elevation: 10,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _hangup,
                      child: const Padding(
                        padding: EdgeInsets.all(22.0),
                        child: Icon(
                          Icons.call_end,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Speaker
                  _buildControl(
                    icon: _speaker ? Icons.volume_up : Icons.volume_off,
                    label: _speaker ? 'Speaker' : 'Speaker',
                    color: _speaker
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    onTap: _toggleSpeaker,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControl({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final isActive = color == Theme.of(context).colorScheme.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: color,
          shape: const CircleBorder(),
          elevation: 6,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Icon(
                icon,
                size: 26,
                color: isActive
                    ? onPrimary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({required this.progress, required this.color});

  final double progress; // 0..1
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withAlpha((0.95 * 255).round())
      ..style = PaintingStyle.fill;

    final int barCount = 35;
    final double spacing = size.width / (barCount + 1);
    final double centerY = size.height / 2;

    final double time = progress * 2 * math.pi;

    for (int i = 0; i < barCount; i++) {
      final double x = spacing * (i + 1);
      final double phase = i * 0.35;
      final double wave = math.sin(time + phase);
      final double norm = (wave + 1) / 2; // 0..1
      final double barHeight =
          size.height *
          (0.15 + 0.7 * norm * (0.6 + 0.4 * math.sin(i * 0.13 + time)));

      final double top = centerY - barHeight / 2;
      final double left = x - spacing * 0.25;
      final double right = x + spacing * 0.25;
      final rect = Rect.fromLTRB(left, top, right, top + barHeight);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
