import 'package:flutter/material.dart';
// Note: We intentionally avoid adding a hard dependency on a QR package here and
// draw a deterministic placeholder QR-like pattern. If you prefer a real QR
// generator, replace the placeholder with `QrImage(data: roomCode)` from
// the `qr_flutter` package and remove the custom painter.
import 'dart:math' as math;
// dart:ui is not required; Flutter exposes needed types via material.dart

// InviteScreen
// - Big QR code for room invite
// - Room code text below
// - Share button
// - Card with subtle elevation and centered layout

class InviteScreen extends StatelessWidget {
  const InviteScreen({super.key, required this.roomCode});

  final String roomCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Invite')),
      body: Center(
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // QR
                  SizedBox(
                    height: 220,
                    width: 220,
                    child: CustomPaint(painter: _PseudoQrPainter(roomCode)),
                  ),
                  const SizedBox(height: 20),

                  // Room code
                  SelectableText(
                    roomCode,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Share this QR or code with someone on the same network',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(
                        (0.7 * 255).round(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Share button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                      onPressed: () => _onShare(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onShare(BuildContext context) {
    // Placeholder: integrate share_plus or platform-specific sharing later
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share pressed (placeholder)')),
    );
  }
}

class _PseudoQrPainter extends CustomPainter {
  _PseudoQrPainter(this.data);

  final String data;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final bg = Paint()..color = Colors.white;
    // Fill background
    canvas.drawRect(Offset.zero & size, bg);

    const int grid = 21; // simple QR-like grid
    final double cell = size.width / grid;

    // Create deterministic seed from data
    int seed = 0;
    for (var i = 0; i < data.length; i++) {
      seed = (seed * 31 + data.codeUnitAt(i)) & 0x7fffffff;
    }
    final rng = math.Random(seed);

    // Draw finder-like squares in three corners
    void drawFinder(int gx, int gy) {
      final double x = gx * cell;
      final double y = gy * cell;
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, cell * 7, cell * 7),
        Radius.circular(cell),
      );
      canvas.drawRRect(r, paint);
      final inner = RRect.fromRectAndRadius(
        Rect.fromLTWH(x + cell, y + cell, cell * 5, cell * 5),
        Radius.circular(cell * 0.6),
      );
      canvas.drawRRect(inner, bg);
      final dot = RRect.fromRectAndRadius(
        Rect.fromLTWH(x + 2 * cell, y + 2 * cell, cell * 3, cell * 3),
        Radius.circular(cell * 0.4),
      );
      canvas.drawRRect(dot, paint);
    }

    drawFinder(0, 0);
    drawFinder(grid - 7, 0);
    drawFinder(0, grid - 7);

    // Fill remaining cells with pseudo-random pattern
    for (int y = 0; y < grid; y++) {
      for (int x = 0; x < grid; x++) {
        // skip finder areas
        bool inFinder =
            (x < 7 && y < 7) ||
            (x >= grid - 7 && y < 7) ||
            (x < 7 && y >= grid - 7);
        if (inFinder) continue;

        // deterministic random bit based on position and seed
        final int r = rng.nextInt(1000);
        if (r % 3 == 0) {
          final rect = Rect.fromLTWH(
            x * cell + cell * 0.12,
            y * cell + cell * 0.12,
            cell * 0.76,
            cell * 0.76,
          );
          canvas.drawRect(rect, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PseudoQrPainter oldDelegate) =>
      oldDelegate.data != data;
}
