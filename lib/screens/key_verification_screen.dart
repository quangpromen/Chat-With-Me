import 'package:flutter/material.dart';

class KeyVerificationScreen extends StatelessWidget {
  const KeyVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final keys = [
      {'peer': 'Alice', 'verified': true},
      {'peer': 'Bob', 'verified': false},
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Key Verification'),
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...keys.map(
            (k) => Card(
              child: ListTile(
                leading: Icon(
                  (k['verified'] as bool) ? Icons.verified : Icons.error,
                  color: (k['verified'] as bool) ? Colors.green : Colors.red,
                ),
                title: Text(k['peer'] as String),
                trailing: (k['verified'] as bool)
                    ? const Text(
                        'Verified',
                        style: TextStyle(color: Colors.green),
                      )
                    : ElevatedButton(
                        onPressed: () {},
                        child: const Text('Verify'),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
