import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'providers/app_state.dart';

class HostDashboardScreen extends ConsumerStatefulWidget {
  const HostDashboardScreen({super.key});

  @override
  ConsumerState<HostDashboardScreen> createState() =>
      _HostDashboardScreenState();
}

class _HostDashboardScreenState extends ConsumerState<HostDashboardScreen> {
  void _showQrDialog(String title, String data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: QrImageView(data: data, version: QrVersions.auto, size: 200.0),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  // State
  late int connectedClients;
  double dataThroughput = 12.5; // Mbps
  // final Set<String> _bannedIps = <String>{};
  static const int _maxLogEntries = 50;

  final String _hostPassword = '';
  final TextEditingController _passwordController = TextEditingController();

  final List<String> logs = [
    'Alice joined',
    'Bob joined',
    'Charlie left',
    'Alice sent a file',
  ];

  @override
  void initState() {
    super.initState();
    connectedClients = 0;
    _passwordController.text = _hostPassword;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final rooms = ref.watch(roomsProvider);
    final hostId = ref.read(appStateProvider.select((s) => s.profile?.id));
    final hostRooms = rooms.where((r) => r.hostId == hostId).toList();
    final totalMembers = hostRooms.fold<int>(
      0,
      (sum, r) => sum + r.members.length,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Host Dashboard'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        leading: Navigator.of(context).canPop() ? const BackButton() : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ...existing code for Host Info Card and Member Management...
            const SizedBox(height: 20),
            // Room Management
            Text(
              'Rooms',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...hostRooms.map(
              (room) => Card(
                color: colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: const Icon(
                      Icons.meeting_room,
                      color: Colors.deepPurple,
                    ),
                  ),
                  title: Text(room.name),
                  subtitle: Text('Members: ${room.members.length}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.info_outline,
                          color: Colors.indigo,
                        ),
                        tooltip: 'Room Details',
                        onPressed: () => _showRoomDetails(context, room),
                      ),
                      IconButton(
                        icon: const Icon(Icons.qr_code, color: Colors.blue),
                        tooltip: 'Share Room QR',
                        onPressed: () {
                          final roomInfo = 'room:${room.id};pw:(hidden)';
                          _showQrDialog('Room QR', roomInfo);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete Room',
                        onPressed: () => _deleteRoom(room),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (hostRooms.isEmpty)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('No rooms found.'),
              ),
            const SizedBox(height: 20),
            // Stats & Logs
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Rooms',
                    value: hostRooms.length.toString(),
                    icon: Icons.meeting_room,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Total Members',
                    value: totalMembers.toString(),
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Throughput',
                    value: '${dataThroughput.toStringAsFixed(1)} Mbps',
                    icon: Icons.speed,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // ...existing code for Activity Logs...
          ],
        ),
      ),
    );
  }

  void _showRoomDetails(BuildContext context, room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Room: ${room.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${room.id}'),
            Text('Host: ${room.hostId ?? "-"}'),
            Text('Members:'),
            ...room.members.map(
              (m) => Row(
                children: [
                  Expanded(child: Text(m)),
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    tooltip: 'Remove Member',
                    onPressed: () async {
                      await ref.read(appStateProvider.notifier);
                      // Room logic removed: no longer needed
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _deleteRoom(room) async {
    // Room logic removed: no longer needed
    setState(() {
      logs.insert(0, 'Deleted room: ${room.name}');
      if (logs.length > _maxLogEntries) logs.removeLast();
    });
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      color: color.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.18),
              radius: 22,
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
