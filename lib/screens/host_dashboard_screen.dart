import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_state.dart';

class HostDashboardScreen extends ConsumerWidget {
  const HostDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final peers = ref.watch(peersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Host Dashboard')),
      body: peers.isEmpty
          ? const Center(child: Text('No connected clients'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: peers.length,
              itemBuilder: (context, index) {
                final peer = peers[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.computer),
                    title: Text(peer.name),
                    subtitle: Text(peer.ip),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement kick logic
                      },
                      child: const Text('Kick'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
