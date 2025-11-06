import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_state.dart';
import '../data/models/room.dart';

class RoomCreateScreen extends ConsumerStatefulWidget {
  const RoomCreateScreen({super.key});

  @override
  ConsumerState<RoomCreateScreen> createState() => _RoomCreateScreenState();
}

class _RoomCreateScreenState extends ConsumerState<RoomCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  RoomAccessMethod _accessMethod = RoomAccessMethod.open;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Create Room')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Room Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 24),
              Text('Access Method', style: theme.textTheme.titleMedium),
              ListTile(
                title: const Text('Open (anyone can join)'),
                leading: Radio<RoomAccessMethod>(
                  value: RoomAccessMethod.open,
                  groupValue: _accessMethod,
                  onChanged: (v) => setState(() => _accessMethod = v!),
                ),
              ),
              ListTile(
                title: const Text('Password required'),
                leading: Radio<RoomAccessMethod>(
                  value: RoomAccessMethod.password,
                  groupValue: _accessMethod,
                  onChanged: (v) => setState(() => _accessMethod = v!),
                ),
              ),
              if (_accessMethod == RoomAccessMethod.password)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Room Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (v) =>
                        _accessMethod == RoomAccessMethod.password &&
                            (v == null || v.isEmpty)
                        ? 'Enter a password'
                        : null,
                  ),
                ),
              ListTile(
                title: const Text('Manual approval (host must approve)'),
                leading: Radio<RoomAccessMethod>(
                  value: RoomAccessMethod.manual,
                  groupValue: _accessMethod,
                  onChanged: (v) => setState(() => _accessMethod = v!),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Create Room'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    ref
                        .read(appStateProvider.notifier)
                        .createRoom(
                          _nameController.text.trim(),
                          password: _accessMethod == RoomAccessMethod.password
                              ? _passwordController.text
                              : null,
                          accessMethod: _accessMethod,
                        );
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
