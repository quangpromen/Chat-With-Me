import 'package:flutter/material.dart';

class CallOngoingScreen extends StatelessWidget {
  const CallOngoingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ongoing Call')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.call, size: 64, color: Colors.orange),
            const SizedBox(height: 24),
            const Text('In call with Alice'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.call_end),
              label: const Text('End Call'),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
