import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// KeyVerificationScreen
// - Camera preview for scanning QR codes (MobileScanner)
// - Below camera: fingerprint code displayed in groups (ABCDE-FGHIJ-KLMNO)
// - "Mark as Verified" button enabled when a valid code is scanned
// - Handles invalid/erroneous QR gracefully

class KeyVerificationScreen extends ConsumerStatefulWidget {
  const KeyVerificationScreen({super.key});

  @override
  ConsumerState<KeyVerificationScreen> createState() =>
      _KeyVerificationScreenState();
}

class _KeyVerificationScreenState extends ConsumerState<KeyVerificationScreen> {
  final MobileScannerController _controller = MobileScannerController();
  String? _scannedRaw;
  String? _scannedGrouped;
  String? _error;
  bool _verified = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (capture.barcodes.isEmpty) return;
    final barcode = capture.barcodes.first;
    final raw = barcode.rawValue ?? barcode.displayValue ?? '';
    if (raw.isEmpty) return;

    // Validate and normalize: allow alphanumeric, uppercase, length 15
    final normalized = raw
        .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
        .toUpperCase();
    if (normalized.length != 15) {
      setState(() {
        _scannedRaw = raw;
        _scannedGrouped = null;
        _error = 'Invalid code scanned';
      });
      return;
    }

    final grouped =
        '${normalized.substring(0, 5)}-${normalized.substring(5, 10)}-${normalized.substring(10, 15)}';

    setState(() {
      _scannedRaw = raw;
      _scannedGrouped = grouped;
      _error = null;
    });
  }

  void _markVerified() {
    if (_scannedGrouped == null) return;
    setState(() {
      _verified = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Key ${_scannedGrouped!} marked as verified')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Key')),
      body: Column(
        children: [
          // Camera preview area
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Card(
              margin: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 6,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(controller: _controller, onDetect: _onDetect),
                    // overlay for scanning hint
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 12,
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        color: Colors.black45,
                        child: Text(
                          'Point the camera at a QR containing the key',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Scanned fingerprint display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (_error != null) ...[
                      Text(
                        _error!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    Text(
                      _scannedGrouped ?? 'No key scanned',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),
                    if (_scannedRaw != null && _scannedGrouped == null)
                      Text(
                        'Scanned: "${_scannedRaw!}"',
                        style: theme.textTheme.bodySmall,
                      ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _scannedGrouped != null && !_verified
                              ? _markVerified
                              : null,
                          icon: const Icon(Icons.check),
                          label: const Text('Mark as Verified'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _scannedRaw = null;
                              _scannedGrouped = null;
                              _error = null;
                              _verified = false;
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reset'),
                        ),
                      ],
                    ),

                    if (_verified) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Verified',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),
          Expanded(child: Container()),
        ],
      ),
    );
  }
}
