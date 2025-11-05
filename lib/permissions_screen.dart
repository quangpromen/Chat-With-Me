import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// PermissionsScreen
// - Lists three permission cards: Local Network Access, Storage Access, Microphone Access
// - Each card has an icon, title, hint text, and a toggle switch
// - Continue button is enabled only when all toggles are ON
// - Material 3 friendly, rounded cards, consistent padding

const _kPadding = EdgeInsets.all(16);
const _kCardRadius = BorderRadius.all(Radius.circular(18));

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  // Route example: '/permissions'
  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> {
  bool _localNetwork = false;
  bool _storage = false;
  bool _microphone = false;

  bool get _allEnabled => _localNetwork && _storage && _microphone;

  void _toggleLocalNetwork(bool v) => setState(() => _localNetwork = v);
  void _toggleStorage(bool v) => setState(() => _storage = v);
  void _toggleMicrophone(bool v) => setState(() => _microphone = v);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {}, // placeholder for help/about
            tooltip: 'Why permissions',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: _kPadding,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _permissionCard(
                      context,
                      icon: Icons.wifi_tethering,
                      title: 'Local Network Access',
                      hint:
                          'Allow discovery and communication with devices on the same LAN. Required for offline chat and calls.',
                      value: _localNetwork,
                      onChanged: _toggleLocalNetwork,
                    ),
                    const SizedBox(height: 12),
                    _permissionCard(
                      context,
                      icon: Icons.sd_storage,
                      title: 'Storage Access',
                      hint: 'Allow sending and saving files to local storage.',
                      value: _storage,
                      onChanged: _toggleStorage,
                    ),
                    const SizedBox(height: 12),
                    _permissionCard(
                      context,
                      icon: Icons.mic,
                      title: 'Microphone Access',
                      hint: 'Allow voice capture for local-network calls.',
                      value: _microphone,
                      onChanged: _toggleMicrophone,
                    ),
                  ],
                ),
              ),

              // Continue button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _allEnabled
                            ? () {
                                // Placeholder: proceed into the app
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Continue'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _permissionCard(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String hint,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: _kCardRadius),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rounded icon container
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 28, color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(hint, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Toggle
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Switch(
                value: value,
                onChanged: onChanged,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
