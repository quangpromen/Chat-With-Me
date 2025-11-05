import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode _themeMode = ThemeMode.system;
  String _language = 'English';
  bool _preferLan = true;
  String _stunServer = '';
  String _turnServer = '';
  bool _notificationsEnabled = true;
  bool _requireVerification = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsCard(
            title: 'General',
            child: Column(
              children: [
                ListTile(
                  title: const Text('Theme'),
                  trailing: DropdownButton<ThemeMode>(
                    value: _themeMode,
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Light'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('System'),
                      ),
                    ],
                    onChanged: (mode) => setState(() => _themeMode = mode!),
                  ),
                ),
                ListTile(
                  title: const Text('Language'),
                  trailing: DropdownButton<String>(
                    value: _language,
                    items: const [
                      DropdownMenuItem(
                        value: 'English',
                        child: Text('English'),
                      ),
                      DropdownMenuItem(
                        value: 'Spanish',
                        child: Text('Spanish'),
                      ),
                      DropdownMenuItem(value: 'French', child: Text('French')),
                    ],
                    onChanged: (lang) => setState(() => _language = lang!),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SettingsCard(
            title: 'Network',
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Prefer LAN'),
                  value: _preferLan,
                  onChanged: (v) => setState(() => _preferLan = v),
                ),
                ListTile(
                  title: const Text('STUN Server'),
                  subtitle: TextField(
                    decoration: const InputDecoration(
                      hintText: 'stun:example.com',
                    ),
                    controller: TextEditingController(text: _stunServer),
                    onChanged: (v) => setState(() => _stunServer = v),
                  ),
                ),
                ListTile(
                  title: const Text('TURN Server'),
                  subtitle: TextField(
                    decoration: const InputDecoration(
                      hintText: 'turn:example.com',
                    ),
                    controller: TextEditingController(text: _turnServer),
                    onChanged: (v) => setState(() => _turnServer = v),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SettingsCard(
            title: 'Notifications',
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Enable Notifications'),
                  value: _notificationsEnabled,
                  onChanged: (v) => setState(() => _notificationsEnabled = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SettingsCard(
            title: 'Security',
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Require Verification'),
                  value: _requireVerification,
                  onChanged: (v) => setState(() => _requireVerification = v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SettingsCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
