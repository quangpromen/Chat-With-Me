import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_offline/core/discovery_service.dart';
import 'package:chat_offline/core/signaling_service.dart';

// DiscoveryScreen
// - Connection banner (Scanning / Connected / No Host Found)
// - List of detected hosts (ListTile with name, IP, status chip)
// - FAB “Host this Network”
// - Button “Enter Host IP manually”
// - Shimmer-like loading placeholders while scanning (no external deps)

const _kPadding = EdgeInsets.all(16);
const _kRadius = BorderRadius.all(Radius.circular(18));

class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  // Route suggestion: '/discovery'
  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class Host {
  Host({required this.name, required this.ip, this.port, this.connected = false});
  final String name;
  final String ip;
  final int? port;
  bool connected;
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen>
    with SingleTickerProviderStateMixin {
  bool _scanning = true;
  bool _connected = false; // whether we have connected to a host
  final List<Host> _hosts = [];
  bool _hosting = false;
  int? _connectingIndex;

  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _scanHosts();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _scanHosts() async {
    setState(() {
      _scanning = true;
      _connectingIndex = null;
    });
    final discovery = ref.read(discoveryServiceProvider);
    final signaling = ref.read(signalingServiceProvider);
    final endpoint = signaling.connectedEndpoint;
    try {
      final peers = await discovery.scanPeers();
      if (!mounted) return;
      setState(() {
        _hosts
          ..clear()
          ..addAll(
            peers.map((peer) {
              final ip = peer['ip'] as String? ?? '0.0.0.0';
              final port = (peer['port'] as int?) ?? 8080;
              final isConnected = (endpoint != null &&
                      (endpoint == '$ip:$port' || endpoint == ip)) ||
                  (discovery.isHost && discovery.hostIp == ip);
              return Host(
                name: peer['deviceId'] as String? ?? 'Unknown peer',
                ip: ip,
                port: port,
                connected: isConnected,
              );
            }),
          );
        _connected = _hosts.any((host) => host.connected);
        _scanning = false;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _hosts.clear();
        _scanning = false;
      });
      _showSnackBar('Unable to scan for hosts: $err');
    }
  }

  Future<void> _startHosting() async {
    setState(() {
      _hosting = true;
      _connected = false;
      _connectingIndex = null;
    });

    final discovery = ref.read(discoveryServiceProvider);
    final signaling = ref.read(signalingServiceProvider);
    try {
  await signaling.startServer(port: 8080);
  await discovery.advertiseSelf(port: 8080, asHost: true);
      final selfEndpoint = '${discovery.hostIp ?? '0.0.0.0'}:8080';
      signaling.connectedEndpoint = selfEndpoint;
      if (!mounted) return;
      setState(() {
        _connected = true;
        _hosting = false;
        final selfHost = Host(
          name: 'This device',
          ip: discovery.hostIp ?? '0.0.0.0',
          port: 8080,
          connected: true,
        );
        _hosts.removeWhere((h) => h.ip == selfHost.ip && h.port == selfHost.port);
        _hosts.insert(0, selfHost);
      });
      _showSnackBar('Hosting started on ${discovery.hostIp ?? 'local network'}');
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _hosting = false;
      });
      _showSnackBar('Failed to start hosting: $err');
    }
  }

  void _enterIpManually() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        final portController = TextEditingController(text: '8080');
        return AlertDialog(
          title: const Text('Enter Host IP'),
          actionsPadding: const EdgeInsets.only(bottom: 12, right: 16),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: 'e.g. 192.168.0.5'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: portController,
                decoration: const InputDecoration(hintText: 'Port (default 8080)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final ip = controller.text.trim();
                final port = int.tryParse(portController.text.trim());
                if (ip.isEmpty || port == null) {
                  return;
                }
                final host = Host(name: 'Manual Host', ip: ip, port: port);
                setState(() {
                  _hosts.removeWhere(
                    (h) => h.ip == host.ip && h.port == host.port,
                  );
                  _hosts.insert(0, host);
                });
                Navigator.of(context).pop();
                _attemptConnect(0);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _attemptConnect(int index) async {
    if (index < 0 || index >= _hosts.length) return;
    final host = _hosts[index];
    setState(() {
      _connectingIndex = index;
      _connected = false;
      for (final h in _hosts) {
        h.connected = false;
      }
    });

    final signaling = ref.read(signalingServiceProvider);
    try {
      await signaling.connectToHost(host.ip, port: host.port ?? 8080);
      if (!mounted) return;
      setState(() {
        host.connected = true;
        _connected = true;
        _connectingIndex = null;
      });
      _showSnackBar('Connected to ${host.name}');
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _connectingIndex = null;
      });
      _showSnackBar('Failed to connect: $err');
    }
  }

  Widget _buildBanner() {
    if (_scanning) {
      return _StatusBanner(
        text: 'Scanning for hosts...',
        color: Colors.orange,
        icon: Icons.search,
      );
    }
    if (_connected) {
      return _StatusBanner(
        text: 'Connected',
        color: Colors.green,
        icon: Icons.check_circle,
      );
    }
    if (_hosts.isNotEmpty) {
      return _StatusBanner(
        text: 'Hosts available',
        color: Colors.blue,
        icon: Icons.devices,
      );
    }
    return _StatusBanner(
      text: 'No host found',
      color: Colors.red,
      icon: Icons.error_outline,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discovery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _scanHosts();
            },
            tooltip: 'Rescan',
          ),
        ],
      ),
      body: Padding(
        padding: _kPadding,
        child: Column(
          children: [
            _buildBanner(),
            const SizedBox(height: 12),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: _kRadius),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: _scanning ? _buildShimmerList() : _buildHostList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _enterIpManually,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Enter Host IP manually'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _hosting ? null : _startHosting,
        icon: _hosting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.wifi_tethering),
        label: Text(_hosting ? 'Starting...' : 'Host this Network'),
      ),
    );
  }

  Widget _buildHostList() {
    if (_hosts.isEmpty) {
      return Center(
        child: Text(
          'No hosts discovered yet.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return ListView.separated(
      itemCount: _hosts.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final h = _hosts[index];
        return ListTile(
          leading: CircleAvatar(
            child: Icon(h.connected ? Icons.check : Icons.computer),
          ),
          title: Text(h.name),
          subtitle: Text('${h.ip}${h.port != null ? ':${h.port}' : ''}'),
          trailing: _connectingIndex == index
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Chip(
                  label: Text(h.connected ? 'Connected' : 'Available'),
                  backgroundColor: h.connected
                      ? Colors.green.shade50
                      : Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                ),
          onTap: () => _attemptConnect(index),
        );
      },
    );
  }

  Widget _buildShimmerList() {
    // Build several shimmer placeholder rows
    return ListView.separated(
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => Row(
        children: [
          _ShimmerBox(width: 48, height: 48, controller: _shimmerController),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(height: 12, controller: _shimmerController),
                const SizedBox(height: 8),
                _ShimmerBox(
                  width: 120,
                  height: 10,
                  controller: _shimmerController,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.text,
    required this.color,
    required this.icon,
  });
  final String text;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha((0.12 * 255).round()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    this.width = double.infinity,
    required this.height,
    required this.controller,
  });
  final double width;
  final double height;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final shimmerPosition = controller.value;
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ShaderMask(
            shaderCallback: (rect) {
              return LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.surfaceContainerHighest,
                  Theme.of(
                    context,
                  ).colorScheme.onSurface.withAlpha((0.08 * 255).round()),
                  Theme.of(context).colorScheme.surfaceContainerHighest,
                ],
                stops: [
                  (shimmerPosition - 0.3).clamp(0.0, 1.0),
                  shimmerPosition.clamp(0.0, 1.0),
                  (shimmerPosition + 0.3).clamp(0.0, 1.0),
                ],
                begin: Alignment(-1.0, -0.3),
                end: Alignment(1.0, 0.3),
              ).createShader(rect);
            },
            blendMode: BlendMode.srcATop,
            child: Container(
              width: width,
              height: height,
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
        );
      },
    );
  }
}
