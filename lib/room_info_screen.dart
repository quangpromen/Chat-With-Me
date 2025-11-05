import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// RoomInfoScreen
// - Room name, description
// - Members list with avatar, name, and role badge
// - Invite button (QR or code) — placeholder UI
// - Action buttons: Leave Room, Mute Notifications
// - Supports modal sheet presentation via showAsModal

const _kPadding = EdgeInsets.all(16);
const _kRadius = BorderRadius.all(Radius.circular(16));

class RoomInfoScreen extends ConsumerStatefulWidget {
  const RoomInfoScreen({
    super.key,
    required this.roomName,
    required this.roomDescription,
  });

  final String roomName;
  final String roomDescription;

  static Future<void> showAsModal(
    BuildContext context, {
    required String roomName,
    required String roomDescription,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.82,
          child: RoomInfoScreen(
            roomName: roomName,
            roomDescription: roomDescription,
          ),
        ),
      ),
    );
  }

  @override
  ConsumerState<RoomInfoScreen> createState() => _RoomInfoScreenState();
}

class _Member {
  _Member({required this.name, required this.role});
  final String name;
  final String role;
}

class _RoomInfoScreenState extends ConsumerState<RoomInfoScreen> {
  final List<_Member> _members = [
    _Member(name: 'Alice', role: 'Admin'),
    _Member(name: 'Bob', role: 'Moderator'),
    _Member(name: 'Charlie', role: 'Member'),
    _Member(name: 'Dana', role: 'Member'),
  ];

  bool _muted = false;

  void _invite() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Invite'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.qr_code, size: 80),
            SizedBox(height: 12),
            Text('QR code and invite code placeholder'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _leaveRoom() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave room?'),
        content: const Text('Are you sure you want to leave this room?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).maybePop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Left room (placeholder)')),
              );
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: _kPadding,
        child: Column(
          children: [
            // Drag handle
            Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 12),

            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: const Icon(Icons.group),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.roomName,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.roomDescription,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _invite,
                  icon: const Icon(Icons.person_add_alt_1),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Members
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: _kRadius),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Members',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.separated(
                          itemCount: _members.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 12),
                          itemBuilder: (context, index) {
                            final m = _members[index];
                            return ListTile(
                              leading: CircleAvatar(child: Text(m.name[0])),
                              title: Text(m.name),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  m.role,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _invite,
                    icon: const Icon(Icons.qr_code),
                    label: const Text('Invite'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _leaveRoom,
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text('Leave Room'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Mute Notifications'),
                    value: _muted,
                    onChanged: (v) => setState(() => _muted = v),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
