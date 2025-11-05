import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_state.dart';

class PermissionsScreen extends ConsumerWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(permissionsProvider);
    final notifier = ref.read(appStateProvider.notifier);
    final hasAll = ref.watch(
      appStateProvider.select((state) => state.hasAllPermissions),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Permissions')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Row(
                      children: const [
                        Icon(Icons.wifi, color: Colors.indigo),
                        SizedBox(width: 8),
                        Text('Local Network'),
                      ],
                    ),
                    value: permissions.contains(AppPermission.network),
                    onChanged: (v) =>
                        notifier.setPermission(AppPermission.network, v),
                  ),
                  SwitchListTile(
                    title: Row(
                      children: [
                        const Icon(Icons.sd_storage, color: Colors.indigo),
                        const SizedBox(width: 8),
                        const Text('Storage'),
                      ],
                    ),
                    value: permissions.contains(AppPermission.storage),
                    onChanged: (v) =>
                        notifier.setPermission(AppPermission.storage, v),
                  ),
                  SwitchListTile(
                    title: Row(
                      children: [
                        const Icon(Icons.mic, color: Colors.indigo),
                        const SizedBox(width: 8),
                        const Text('Microphone'),
                      ],
                    ),
                    value: permissions.contains(AppPermission.microphone),
                    onChanged: (v) =>
                        notifier.setPermission(AppPermission.microphone, v),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Continue'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: hasAll ? () => context.go('/profile-setup') : null,
          ),
        ],
      ),
    );
  }
}
