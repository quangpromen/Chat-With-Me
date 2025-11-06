import 'package:flutter/material.dart';

class PeersScreen extends StatelessWidget {
  const PeersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final peers = [
      {'id': 'peer1', 'name': 'Alice'},
      {'id': 'peer2', 'name': 'Bob'},
      {'id': 'peer3', 'name': 'Charlie'},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Peers'), leading: const BackButton()),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...peers.map(
            (peer) => Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo[100],
                  child: Text(peer['name']![0]),
                ),
                title: Text(
                  peer['name']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
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
