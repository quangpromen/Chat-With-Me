import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_state.dart';
import '../data/models/room.dart';

class RoomSettingsScreen extends ConsumerWidget {
  final Room room;
  const RoomSettingsScreen({super.key, required this.room});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final _passwordController = TextEditingController(
      text: room.password ?? '',
    );
    RoomAccessMethod _accessMethod = room.accessMethod;
    return Scaffold(
      appBar: AppBar(title: const Text('Room Settings')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Room Name', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(room.name, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 24),
            Text('Access Method', style: theme.textTheme.titleMedium),
            ListTile(
              title: const Text('Open (anyone can join)'),
              leading: Radio<RoomAccessMethod>(
                value: RoomAccessMethod.open,
                groupValue: _accessMethod,
                onChanged: (v) {}, // TODO: implement update
              ),
            ),
            ListTile(
              title: const Text('Password required'),
              leading: Radio<RoomAccessMethod>(
                value: RoomAccessMethod.password,
                groupValue: _accessMethod,
                onChanged: (v) {}, // TODO: implement update
              ),
            ),
            if (_accessMethod == RoomAccessMethod.password)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Room Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ),
            ListTile(
              title: const Text('Manual approval (host must approve)'),
              leading: Radio<RoomAccessMethod>(
                value: RoomAccessMethod.manual,
                groupValue: _accessMethod,
                onChanged: (v) {}, // TODO: implement update
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                // TODO: Call provider to update room settings
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 32),
            Divider(),
            Text('Security', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('End-to-end encryption is enabled for this room.'),
            // TODO: Show encryption key/fingerprint, allow export/share, rotate key, etc.
          ],
        ),
      ),
    );
  }
}
