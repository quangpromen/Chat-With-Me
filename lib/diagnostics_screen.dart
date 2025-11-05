import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  // Dummy test results
  final List<_DiagTest> tests = [
    _DiagTest('mDNS status', Icons.wifi_tethering, true),
    _DiagTest('UDP broadcast', Icons.waves, false),
    _DiagTest('WebSocket port', Icons.cloud, true),
    _DiagTest('Permissions', Icons.lock, true),
  ];

  void _generateReport() async {
    final data = <String, dynamic>{
      'generatedAt': DateTime.now().toUtc().toIso8601String(),
      'summary': {
        'total': tests.length,
        'passed': tests.where((t) => t.pass).length,
        'failed': tests.where((t) => !t.pass).length,
        'overallPass': tests.every((t) => t.pass),
      },
      'results': tests
          .map(
            (t) => {
              'label': t.label,
              'pass': t.pass,
            },
          )
          .toList(growable: false),
    };

    final encoder = const JsonEncoder.withIndent('  ');
    final payload = encoder.convert(data);

    try {
      await Clipboard.setData(ClipboardData(text: payload));
    } on PlatformException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to generate report.')),
      );
      return;
    }

    if (!mounted) return;

    // Show the report preview so the operator can copy/save it immediately.
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Diagnostics Report Ready'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'A JSON report was copied to your clipboard. '
                'Paste it into a support ticket or save it for later analysis.',
              ),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 160),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    payload,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostics')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...tests.map(
              (t) => Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Icon(t.icon, size: 32),
                  title: Text(t.label),
                  trailing: Chip(
                    label: Text(t.pass ? 'PASS' : 'FAIL'),
                    backgroundColor: t.pass
                        ? Colors.green[100]
                        : Colors.red[100],
                    labelStyle: TextStyle(
                      color: t.pass ? Colors.green[900] : Colors.red[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.description),
              label: const Text('Generate Report'),
              onPressed: _generateReport,
            ),
          ],
        ),
      ),
    );
  }
}

class _DiagTest {
  final String label;
  final IconData icon;
  final bool pass;
  const _DiagTest(this.label, this.icon, this.pass);
}
