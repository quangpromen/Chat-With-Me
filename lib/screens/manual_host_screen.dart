import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_offline/core/signaling_service.dart';

const _kPadding = EdgeInsets.all(16);
const _kRadius = BorderRadius.all(Radius.circular(16));

class ManualHostScreen extends ConsumerStatefulWidget {
  const ManualHostScreen({super.key});

  @override
  ConsumerState<ManualHostScreen> createState() => _ManualHostScreenState();
}

class _ManualHostScreenState extends ConsumerState<ManualHostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ipController = TextEditingController();
  final _portController = TextEditingController();

  final List<String> _history = [];
  bool _connecting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _portController.text = '8080';
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  String? _validateIp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'IP is required';
    }
    final ip = value.trim();
    final parts = ip.split('.');
    if (parts.length != 4) {
      return 'Enter a valid IPv4 address';
    }
    for (final part in parts) {
      final parsed = int.tryParse(part);
      if (parsed == null || parsed < 0 || parsed > 255) {
        return 'Enter a valid IPv4 address';
      }
    }
    return null;
  }

  String? _validatePort(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Port is required';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed <= 0 || parsed > 65535) {
      return 'Enter a port between 1 and 65535';
    }
    return null;
  }

  void _connect() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      return;
    }
    final ip = _ipController.text.trim();
    final port = _portController.text.trim();
    final parsedPort = int.parse(port);
    _attemptConnection(ip, parsedPort);
  }

  void _useHistory(String entry) {
    final parts = entry.split(':');
    if (parts.length >= 2) {
      _ipController.text = parts[0];
      _portController.text = parts[1];
      setState(() {});
    }
  }

  Future<void> _attemptConnection(String ip, int port) async {
    FocusScope.of(context).unfocus();
    final entry = '$ip:$port';
    setState(() {
      _connecting = true;
      _errorMessage = null;
      _history.remove(entry);
      _history.insert(0, entry);
      if (_history.length > 8) {
        _history.removeLast();
      }
    });

    final signaling = ref.read(signalingServiceProvider);
    try {
      await signaling.connectToHost(ip, port: port);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connected to $entry')),
      );
    } on FormatException catch (err) {
      setState(() => _errorMessage = err.message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.message)),
      );
    } catch (err) {
      setState(() => _errorMessage = 'Unable to connect to $entry');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection failed: $err')),
      );
    } finally {
      if (mounted) {
        setState(() => _connecting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Host Manually')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: _kRadius),
            elevation: 2,
            child: Padding(
              padding: _kPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _ipController,
                          decoration: const InputDecoration(
                            labelText: 'IP Address',
                            hintText: '192.168.0.5',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: false,
                          ),
                          validator: _validateIp,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _portController,
                          decoration: const InputDecoration(
                            labelText: 'Port',
                            hintText: '8080',
                          ),
                          keyboardType: TextInputType.number,
                          validator: _validatePort,
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _connecting ? null : _connect,
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _connecting
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Connect'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_history.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Recent',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final entry = _history[index];
                          return ActionChip(
                            label: Text(entry),
                            onPressed: () => _useHistory(entry),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemCount: _history.length,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
