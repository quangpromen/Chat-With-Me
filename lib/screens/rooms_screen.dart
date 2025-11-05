import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_state.dart';
import '../widgets/common.dart';

class RoomsScreen extends ConsumerWidget {
  const RoomsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = ref.watch(roomsProvider);
    final isHosting = ref.watch(
      appStateProvider.select((state) => state.isHosting),
    );
    final messageLookup = ref.watch(
      appStateProvider.select((state) => state.messagesByRoom),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Rooms')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (isHosting)
            const ConnectionBanner(label: 'You are hosting this network'),
          if (rooms.isEmpty)
            Card(
              elevation: 1,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'No rooms yet',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    Text('Create a room to start chatting on this network.'),
                  ],
                ),
              ),
            ),
          for (final room in rooms)
            Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo[100],
                  child: Text(
                    room.name.isNotEmpty ? room.name[0].toUpperCase() : 'R',
                    style: const TextStyle(color: Colors.indigo),
                  ),
                ),
                title: Text(
                  room.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: _RoomSubtitle(
                  lastMessage: _lastMessagePreview(
                    messageLookup[room.id] ?? const [],
                  ),
                ),
                trailing: FilledButton(
                  onPressed: () => context.go('/chat/${room.id}'),
                  child: const Text('Join'),
                ),
                onTap: () => context.go('/chat/${room.id}'),
              ),
            ),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Create Room'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: () => context.push('/room-create'),
          ),
        ],
      ),
    );
  }
}

class _RoomSubtitle extends StatelessWidget {
  const _RoomSubtitle({required this.lastMessage});

  final String? lastMessage;

  @override
  Widget build(BuildContext context) {
    if (lastMessage == null) {
      return const Text('No messages yet');
    }
    return Text(lastMessage!, maxLines: 1, overflow: TextOverflow.ellipsis);
  }
}

String? _lastMessagePreview(List<ChatMessage> messages) {
  if (messages.isEmpty) {
    return null;
  }
  final last = messages.last;
  return '${last.senderName}: ${last.text}';
}
