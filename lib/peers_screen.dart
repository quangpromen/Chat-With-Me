import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// PeersScreen
// - Displays list of LAN peers (avatar, name, status chip)
// - Per-peer buttons: Start Chat, Verify Key

class Peer {
  const Peer({required this.id, required this.name, this.online = true});
  final String id;
  final String name;
  final bool online;
}

class PeersScreen extends ConsumerWidget {
  const PeersScreen({super.key, this.peers});

  // Optional list of peers; when null we use sample placeholder data.
  final List<Peer>? peers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = peers ?? _samplePeers;

    return Scaffold(
      appBar: AppBar(title: const Text('Peers on LAN')),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: items.length,
        separatorBuilder: (context, i) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final p = items[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              radius: 26,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    p.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 8),
                _StatusChip(online: p.online),
              ],
            ),
            subtitle: Text(
              p.online ? 'Available on local network' : 'Last seen offline',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: _PeerActions(
              onStartChat: () => _startChat(context, p),
              onVerifyKey: () => _verifyKey(context, p),
            ),
          );
        },
      ),
    );
  }

  void _startChat(BuildContext context, Peer peer) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Start chat with ${peer.name} (placeholder)')),
    );
  }

  void _verifyKey(BuildContext context, Peer peer) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Verify key for ${peer.name} (placeholder)')),
    );
  }

  static final List<Peer> _samplePeers = const [
    Peer(id: '1', name: 'Alice', online: true),
    Peer(id: '2', name: 'Bob', online: false),
    Peer(id: '3', name: 'Charlie', online: true),
    Peer(id: '4', name: 'Device-42', online: true),
  ];
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.online});
  final bool online;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        online ? 'Online' : 'Offline',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: online ? Colors.green.shade600 : Colors.grey.shade600,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _PeerActions extends StatelessWidget {
  const _PeerActions({required this.onStartChat, required this.onVerifyKey});

  final VoidCallback onStartChat;
  final VoidCallback onVerifyKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onStartChat,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Start Chat'),
        ),
        const SizedBox(width: 8),
        OutlinedButton(onPressed: onVerifyKey, child: const Text('Verify Key')),
      ],
    );
  }
}
