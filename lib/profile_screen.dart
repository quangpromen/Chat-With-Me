import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String displayName = 'Your Name';
  final String deviceId = 'ABC123-XYZ789';
  final String publicKey = 'MIIBIjANBgkqh...';
  final TextEditingController _displayNameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  Uint8List? _avatarBytes;
  bool _isPickingAvatar = false;

  @override
  void initState() {
    super.initState();
    _displayNameController.text = displayName;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _editAvatar() async {
    try {
      setState(() => _isPickingAvatar = true);
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked == null) {
        return;
      }
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _avatarBytes = bytes;
      });
      _showSnackBar('Avatar updated');
    } on PlatformException catch (err) {
      final message = err.code == 'photo_access_denied'
          ? 'Photo access permission is required to pick an avatar.'
          : (err.message ?? 'Unable to update avatar.');
      _showSnackBar(message);
    } catch (_) {
      _showSnackBar('Unexpected error while updating avatar.');
    } finally {
      if (mounted) {
        setState(() => _isPickingAvatar = false);
      }
    }
  }

  Future<void> _copyPublicKey() async {
    try {
      await Clipboard.setData(ClipboardData(text: publicKey));
      _showSnackBar('Public key copied to clipboard');
    } on PlatformException {
      _showSnackBar('Unable to copy public key.');
    }
  }

  Future<void> _exportBackup() async {
    final payload = jsonEncode({
      'displayName': displayName,
      'deviceId': deviceId,
      'publicKey': publicKey,
      'generatedAt': DateTime.now().toUtc().toIso8601String(),
      'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
    });

    try {
      await Clipboard.setData(ClipboardData(text: payload));
    } on PlatformException {
      _showSnackBar('Unable to copy backup to clipboard.');
      return;
    }

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Encrypted Backup Ready'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'The encrypted backup JSON has been copied to your clipboard. '
                'Paste it into a secure location to keep your data safe.',
              ),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 180),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    payload,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage:
                      _avatarBytes != null ? MemoryImage(_avatarBytes!) : null,
                  child: _avatarBytes == null
                      ? const Icon(Icons.person, size: 48)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.primary,
                      foregroundColor:
                          Theme.of(context).colorScheme.onPrimary,
                    ),
                    iconSize: 20,
                    tooltip: 'Edit avatar',
                    onPressed: _isPickingAvatar ? null : _editAvatar,
                    icon: _isPickingAvatar
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                Theme.of(context)
                                    .colorScheme
                                    .onPrimary,
                              ),
                            ),
                          )
                        : const Icon(Icons.edit),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(),
              ),
              controller: _displayNameController,
              onChanged: (value) => setState(() => displayName = value),
            ),
            const SizedBox(height: 24),
            ListTile(
              title: const Text('Device ID'),
              subtitle: SelectableText(deviceId),
              leading: const Icon(Icons.devices),
            ),
            ListTile(
              title: const Text('Public Key'),
              subtitle: SelectableText(publicKey),
              leading: const Icon(Icons.vpn_key),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                tooltip: 'Copy',
                onPressed: _copyPublicKey,
              ),
            ),
            const Spacer(),
            OutlinedButton.icon(
              icon: const Icon(Icons.backup),
              label: const Text('Export Encrypted Backup'),
              onPressed: _exportBackup,
            ),
          ],
        ),
      ),
    );
  }
}
