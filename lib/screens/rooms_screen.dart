import '../chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_state.dart';
import '../widgets/common.dart';
import 'room_settings_screen.dart';

class RoomsScreen extends ConsumerWidget {
  void _joinRoomByKey(BuildContext context, String key) {
    // TODO: Integrate with LAN service and AppState for real join logic
    // Simulate finding room on LAN
    final foundRoom = null; // Replace with actual LAN lookup
    if (foundRoom != null) {
      // TODO: Sync join with AppState and show success dialog
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Tham gia phòng thành công'),
          content: Text('Đã tham gia phòng: ${foundRoom['title']}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Không tìm thấy phòng'),
          content: Text('Không tìm thấy phòng với key: $key trên mạng LAN'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    }
  }

  String _decodeRoomKey(String key) {
    if (key.startsWith('room-')) {
      return key.substring(5);
    }
    return key;
  }

  void _ensureDiscoveryOrHost(WidgetRef ref, bool isHosting) {
    final notifier = ref.read(appStateProvider.notifier);
    if (isHosting) {
      notifier.ensureHostingServer();
    } else {
      notifier.ensureDiscoveryRunning();
    }
  }

  void _showJoinRoomDialog(BuildContext context, WidgetRef ref) {
    final keyController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Join Room by Key/QR'),
          content: TextField(
            controller: keyController,
            decoration: const InputDecoration(labelText: 'Enter Room Key'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final key = keyController.text.trim();
                if (key.isEmpty) return;
                Navigator.of(ctx).pop();
                Navigator.of(ctx).pop();
                _joinRoomByKey(context, key);
              },
              child: const Text('Join'),
            ),
          ],
        );
      },
    );
  }

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
    final theme = Theme.of(context);

    // Ensure discovery/server is running when entering RoomsScreen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureDiscoveryOrHost(ref, isHosting);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rooms'),
        leading: const BackButton(),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () => context.push('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Join Room by Key/QR',
            onPressed: () => _showJoinRoomDialog(context, ref),
          ),
        ],
      ),
      body: Container(
        color: theme.colorScheme.surface,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (isHosting)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ConnectionBanner(label: 'You are hosting this network'),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.dashboard_customize_rounded),
                    label: const Text('Host Dashboard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () => context.push('/host'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            if (rooms.isEmpty)
              Card(
                elevation: 0,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: theme.colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.meeting_room_outlined,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No rooms yet',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create a room to start chatting on this network.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            for (final room in rooms)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Card(
                  color: theme.colorScheme.surfaceContainerHighest,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        room.name.isNotEmpty ? room.name[0].toUpperCase() : 'R',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          room.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        MemberCountBadge(count: room.members.length),
                      ],
                    ),
                    subtitle: RoomSubtitle(
                      lastMessage: lastMessagePreview(
                        messageLookup[room.id] ?? const [],
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.settings),
                      tooltip: 'Room Settings',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RoomSettingsScreen(room: room),
                          ),
                        );
                      },
                    ),
                    onTap: () => context.push('/chat/${room.id}'),
                  ),
                ),
              ),
            const SizedBox(height: 32),
            Center(
              child: FilledButton.icon(
                icon: const Icon(Icons.add_box_rounded),
                label: const Text('Create Room'),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  minimumSize: const Size(180, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  textStyle: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => context.push('/room-create'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MemberCountBadge extends StatelessWidget {
  final int count;
  const MemberCountBadge({required this.count, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.group, size: 14, color: theme.colorScheme.onPrimary),
          const SizedBox(width: 2),
          Text(
            '$count',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class RoomSubtitle extends StatelessWidget {
  final String? lastMessage;
  const RoomSubtitle({required this.lastMessage, super.key});

  @override
  Widget build(BuildContext context) {
    if (lastMessage == null) {
      return const Text('No messages yet');
    }
    return Text(lastMessage!, maxLines: 1, overflow: TextOverflow.ellipsis);
  }
}

String? lastMessagePreview(List<ChatMessage> messages) {
  if (messages.isEmpty) {
    return null;
  }
  final last = messages.last;
  return '${last.sender}: ${last.text}';
}

// --- Custom badge and subtitle widgets ---
class _MemberCountBadge extends StatelessWidget {
  final int count;
  const _MemberCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.group, size: 14, color: theme.colorScheme.onPrimary),
          const SizedBox(width: 2),
          Text(
            '$count',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
            ),
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
