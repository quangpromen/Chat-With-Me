import 'package:flutter/material.dart';

class CallIncomingScreen extends StatelessWidget {
  const CallIncomingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Incoming Call')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.call, size: 64, color: Colors.blue),
            const SizedBox(height: 24),
            const Text('Incoming call from Alice'),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.call),
                  label: const Text('Accept'),
                  onPressed: () {},
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.call_end),
                  label: const Text('Decline'),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
