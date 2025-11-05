import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ProfileSetupScreen
// - Choose avatar (CircleAvatar + camera icon)
// - Enter display name in TextField
// - Save button at the bottom (enabled when a name is entered)
// - Soft elevation card style, friendly empty state, Material 3 compatible

const _kPadding = EdgeInsets.all(16);
const _kCardRadius = BorderRadius.all(Radius.circular(18));

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  // Route suggestion: '/profile_setup'
  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  String _displayName = '';
  // Placeholder for avatar image data; in a real app you'd store a File or bytes
  // For now we toggle between null and a placeholder color
  bool _hasAvatar = false;

  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pickAvatar() {
    // Placeholder: toggle a fake avatar state.
    // Replace with actual image picker / camera flow when adding platform logic.
    setState(() => _hasAvatar = !_hasAvatar);
  }

  void _save() {
    // Placeholder save action. In a real app, persist the profile and navigate on success.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved (placeholder)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSaveEnabled = _displayName.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set up your profile'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: _kPadding,
          child: Column(
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: _kCardRadius),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar chooser
                      GestureDetector(
                        onTap: _pickAvatar,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundColor: _hasAvatar
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer
                                  : Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                              child: _hasAvatar
                                  ? const Icon(Icons.person, size: 48)
                                  : Icon(
                                      Icons.person_outline,
                                      size: 48,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(
                                      (0.12 * 255).round(),
                                    ),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Friendly empty state hint
                      Text(
                        _hasAvatar
                            ? 'Nice avatar!'
                            : 'Add a photo so friends recognize you',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),

                      // Display name field
                      TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          labelText: 'Display name',
                          hintText: 'How should others see you?',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) => setState(() => _displayName = v),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Some optional helper text
              Text(
                'Your display name is shown to other users on the local network. You can change it later in Settings.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Save button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isSaveEnabled ? _save : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Save'),
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
