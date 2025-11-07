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
    final passwordController = TextEditingController(text: room.password ?? '');
    RoomAccessMethod accessMethod = room.accessMethod;
    void saveSettings() {
      ref
          .read(appStateProvider.notifier)
          .updateRoomSettings(
            room.id,
            password: accessMethod == RoomAccessMethod.password
                ? passwordController.text
                : null,
            accessMethod: accessMethod,
          );
      Navigator.of(context).pop();
    }

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
                groupValue: accessMethod,
                onChanged: (v) {
                  accessMethod = v!;
                },
              ),
            ),
            ListTile(
              title: const Text('Password required'),
              leading: Radio<RoomAccessMethod>(
                value: RoomAccessMethod.password,
                groupValue: accessMethod,
                onChanged: (v) {
                  accessMethod = v!;
                },
              ),
            ),
            if (accessMethod == RoomAccessMethod.password)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: TextField(
                  controller: passwordController,
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
                groupValue: accessMethod,
                onChanged: (v) {
                  accessMethod = v!;
                },
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
              onPressed: saveSettings,
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
