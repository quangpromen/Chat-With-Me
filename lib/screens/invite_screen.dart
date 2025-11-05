import 'package:flutter/material.dart';

class InviteScreen extends StatelessWidget {
  const InviteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final peers = [
      {'id': 'peer1', 'name': 'Alice'},
      {'id': 'peer2', 'name': 'Bob'},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Invite Peers')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...peers.map(
            (peer) => Card(
              child: ListTile(
                leading: const Icon(Icons.person_add),
                title: Text(peer['name']!),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Invite'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
