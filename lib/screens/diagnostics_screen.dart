import 'package:flutter/material.dart';

class DiagnosticsScreen extends StatelessWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final diagnostics = [
      {'label': 'Network', 'status': 'OK'},
      {'label': 'Storage', 'status': 'OK'},
      {'label': 'Microphone', 'status': 'OK'},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...diagnostics.map(
            (d) => Card(
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(d['label']!),
                trailing: Text(d['status']!),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
