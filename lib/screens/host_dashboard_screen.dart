import 'package:flutter/material.dart';

class HostDashboardScreen extends StatelessWidget {
  const HostDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clients = [
      {'id': 'peer1', 'name': 'Alice'},
      {'id': 'peer2', 'name': 'Bob'},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Host Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...clients.map(
            (client) => Card(
              child: ListTile(
                leading: const Icon(Icons.computer),
                title: Text(client['name']!),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Kick'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
