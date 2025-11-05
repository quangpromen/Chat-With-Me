import 'package:flutter/material.dart';

class CallOutgoingScreen extends StatelessWidget {
  const CallOutgoingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Outgoing Call')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.call, size: 64, color: Colors.green),
            const SizedBox(height: 24),
            const Text('Calling...'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.call_end),
              label: const Text('Cancel'),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
