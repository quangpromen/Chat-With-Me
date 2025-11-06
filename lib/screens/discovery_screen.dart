import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_state.dart';
import '../widgets/common.dart';

class DiscoveryScreen extends ConsumerWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final peers = ref.watch(peersProvider);
    final appState = ref.watch(appStateProvider);
    final notifier = ref.read(appStateProvider.notifier);
    final bannerLabel = appState.isHosting
        ? 'You are hosting the network'
        : peers.isEmpty
        ? 'Scanning for hosts...'
        : 'Found ${peers.length} device${peers.length == 1 ? '' : 's'}';
    return Scaffold(
      appBar: AppBar(title: const Text('Discovery')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ConnectionBanner(label: bannerLabel),
          if (peers.isEmpty)
            Card(
              elevation: 1,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'No peers discovered yet',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Ensure nearby devices are on the same network and have discovery enabled.',
                    ),
                  ],
                ),
              ),
            )
          else
            ...peers.map(
              (peer) => Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo[100],
                    child: Text(peer.name[0]),
                  ),
                  title: Text(
                    peer.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: peer.isHosting
                        ? () => context.push('/rooms')
                        : null,
                    child: const Text('Connect'),
                  ),
                  subtitle: Text(
                    peer.isHosting
                        ? 'IP: ${peer.ip} • Hosting'
                        : 'IP: ${peer.ip}',
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.wifi),
            label: const Text('Host this Network'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: appState.isHosting
                ? null
                : () {
                    notifier.startHosting();
                    context.push('/rooms');
                  },
          ),
          TextButton(
            onPressed: () {
              context.push('/manual-host');
            },
            child: const Text('Enter Host IP manually'),
          ),
        ],
      ),
    );
  }
}
