import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HostDashboardScreen extends StatefulWidget {
  const HostDashboardScreen({super.key});

  @override
  State<HostDashboardScreen> createState() => _HostDashboardScreenState();
}

class _HostDashboardScreenState extends State<HostDashboardScreen> {
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

  // Dummy data for demonstration
  late int connectedClients;
  int activeRooms = 2;
  double dataThroughput = 12.5; // Mbps
  final Set<String> _bannedIps = <String>{};
  static const int _maxLogEntries = 50;

  bool _hostOnline = true;
  String _hostPassword = '';
  final TextEditingController _passwordController = TextEditingController();

  final List<_DeviceInfo> devices = [
    _DeviceInfo('Alice', '192.168.1.10', '1 min ago', 'Online'),
    _DeviceInfo('Bob', '192.168.1.11', '5 min ago', 'Online'),
    _DeviceInfo('Charlie', '192.168.1.12', '10 min ago', 'Offline'),
  ];

  final List<String> logs = [
    'Alice joined',
    'Bob joined',
    'Charlie left',
    'Alice sent a file',
  ];

  @override
  void initState() {
    super.initState();
    connectedClients = _onlineClientCount();
    _passwordController.text = _hostPassword;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  int _onlineClientCount() {
    return devices.where((d) => d.status == 'Online').length;
  }

  void _kickDevice(int index) {
    final device = devices[index];
    setState(() {
      devices.removeAt(index);
      connectedClients = _onlineClientCount();
      logs.insert(0, 'Kicked ${device.name} (${device.ip})');
      if (logs.length > _maxLogEntries) {
        logs.removeLast();
      }
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Kicked ${device.name}')));
  }

  void _banDevice(int index) {
    final device = devices[index];
    if (_bannedIps.contains(device.ip)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${device.name} is already banned')),
      );
      return;
    }
    setState(() {
      _bannedIps.add(device.ip);
      devices.removeAt(index);
      connectedClients = _onlineClientCount();
      logs.insert(0, 'Banned ${device.name} (${device.ip})');
      if (logs.length > _maxLogEntries) {
        logs.removeLast();
      }
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Banned ${device.name}')));
  }

  void _toggleHostOnline(bool value) {
    setState(() {
      _hostOnline = value;
      logs.insert(0, value ? 'Host started' : 'Host stopped');
      if (logs.length > _maxLogEntries) logs.removeLast();
    });
  }

  void _savePassword() {
    setState(() {
      _hostPassword = _passwordController.text;
      logs.insert(0, 'Host password updated');
      if (logs.length > _maxLogEntries) logs.removeLast();
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Password saved!')));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
            // Host Info Card
            Card(
              color: colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.wifi_tethering,
                          color: colorScheme.primary,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Host Status:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(
                            _hostOnline ? 'Online' : 'Offline',
                            style: TextStyle(color: colorScheme.onPrimary),
                          ),
                          backgroundColor: _hostOnline
                              ? Colors.green.shade600
                              : Colors.red.shade400,
                        ),
                        const Spacer(),
                        Switch(
                          value: _hostOnline,
                          onChanged: _toggleHostOnline,
                          activeColor: colorScheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.lock, color: colorScheme.primary, size: 24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Host Password (optional)',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            obscureText: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _savePassword,
                          icon: const Icon(Icons.save),
                          label: const Text('Save'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.qr_code,
                          color: colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Share Host via QR',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            // Thông tin host có thể là IP, port, password (nếu có)
                            final hostInfo =
                                'host:192.168.1.1;port:8888;pw=$_hostPassword';
                            _showQrDialog('Host QR', hostInfo);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Icon(Icons.qr_code_2, size: 28),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Member Management
            Text(
              'Connected Members',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              color: colorScheme.surfaceVariant,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 2,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: devices.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final d = devices[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: d.status == 'Online'
                          ? Colors.green.shade100
                          : Colors.grey.shade300,
                      child: Text(
                        d.name[0],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      d.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Text('${d.ip} • Last seen: ${d.lastSeen}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Chip(
                          label: Text(
                            d.status,
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: d.status == 'Online'
                              ? Colors.green
                              : Colors.red,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.orange,
                          ),
                          tooltip: 'Kick',
                          onPressed: () => _kickDevice(index),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.block,
                            color: Colors.redAccent,
                          ),
                          tooltip: 'Ban',
                          onPressed: () => _banDevice(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Room Management
            Text(
              'Rooms',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              color: colorScheme.surfaceVariant,
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
                title: const Text('Room 1'),
                subtitle: const Text('Members: 3'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.qr_code, color: Colors.blue),
                      tooltip: 'Share Room QR',
                      onPressed: () {
                        // Thông tin room có thể là roomId, password (nếu có)
                        final roomInfo = 'room:Room1;pw=$_hostPassword';
                        _showQrDialog('Room QR', roomInfo);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Delete Room',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Stats & Logs
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Clients',
                    value: connectedClients.toString(),
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Rooms',
                    value: activeRooms.toString(),
                    icon: Icons.meeting_room,
                    color: Colors.deepPurple,
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
            Text(
              'Activity Logs',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              color: colorScheme.surfaceVariant,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  height: 120,
                  child: ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, i) => Text(
                      '• ${logs[i]}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
              child: Icon(icon, color: color, size: 28),
              radius: 22,
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

class _DeviceInfo {
  final String name;
  final String ip;
  final String lastSeen;
  final String status;
  const _DeviceInfo(this.name, this.ip, this.lastSeen, this.status);
}
