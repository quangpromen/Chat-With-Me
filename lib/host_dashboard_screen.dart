import 'package:flutter/material.dart';

class HostDashboardScreen extends StatefulWidget {
  const HostDashboardScreen({super.key});

  @override
  State<HostDashboardScreen> createState() => _HostDashboardScreenState();
}

class _HostDashboardScreenState extends State<HostDashboardScreen> {
  // Dummy data for demonstration
  late int connectedClients;
  int activeRooms = 2;
  double dataThroughput = 12.5; // Mbps
  final Set<String> _bannedIps = <String>{};
  static const int _maxLogEntries = 50;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Host Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatCard(
                  title: 'Clients',
                  value: connectedClients.toString(),
                  icon: Icons.people,
                ),
                _StatCard(
                  title: 'Rooms',
                  value: activeRooms.toString(),
                  icon: Icons.meeting_room,
                ),
                _StatCard(
                  title: 'Throughput',
                  value: '${dataThroughput.toStringAsFixed(1)} Mbps',
                  icon: Icons.speed,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Connected Devices',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: ListView.separated(
                  itemCount: devices.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final d = devices[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text(d.name[0])),
                      title: Text(d.name),
                      subtitle: Text('${d.ip} • Last seen: ${d.lastSeen}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            d.status,
                            style: TextStyle(
                              color: d.status == 'Online'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            tooltip: 'Kick',
                            onPressed: () => _kickDevice(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.block),
                            tooltip: 'Ban',
                            onPressed: () => _banDevice(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Logs', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  height: 100,
                  child: ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, i) => Text(logs[i]),
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
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Column(
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
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
