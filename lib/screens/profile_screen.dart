import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_state.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(appStateProvider.select((s) => s.profile));
    final theme = Theme.of(context);
    final nameController = TextEditingController(
      text: profile?.displayName ?? '',
    );
    final avatarController = TextEditingController(
      text: profile?.avatarPath ?? '',
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), leading: const BackButton()),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: theme.colorScheme.primaryContainer,
                backgroundImage:
                    (profile?.avatarPath != null &&
                        profile!.avatarPath!.isNotEmpty)
                    ? AssetImage(profile.avatarPath!) as ImageProvider
                    : null,
                child:
                    (profile?.avatarPath == null ||
                        profile!.avatarPath!.isEmpty)
                    ? Icon(
                        Icons.person,
                        size: 48,
                        color: theme.colorScheme.primary,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            Text('Display Name', style: theme.textTheme.titleMedium),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Your name',
              ),
            ),
            const SizedBox(height: 16),
            Text('Avatar Path (optional)', style: theme.textTheme.titleMedium),
            TextField(
              controller: avatarController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'assets/avatar.png',
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                ref
                    .read(appStateProvider.notifier)
                    .saveProfile(
                      nameController.text.trim(),
                      avatarPath: avatarController.text.trim(),
                    );
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
