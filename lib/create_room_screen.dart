import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

// CreateRoomScreen
// - TextFields: Room Name, Description
// - SegmentedButton: Room Type (Open / Invite)
// - Create button at bottom
// - Success snackbar after creation

const _kPadding = EdgeInsets.all(16);
const _kRadius = BorderRadius.all(Radius.circular(16));

enum RoomType { open, invite }

class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});

  // Route suggestion: '/create_room'
  @override
  ConsumerState<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  RoomType _type = RoomType.open;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _createRoom() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    final name = _nameController.text.trim();
    final desc = _descController.text.trim();

    // Tạo key cho phòng (demo: dùng tên phòng, thực tế nên dùng id hoặc mã hóa)
    final roomKey = _generateRoomKey(name);

    final descText = desc.isNotEmpty ? ' — $desc' : '';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Room "$name" created (${_type == RoomType.open ? 'Open' : 'Invite'})$descText',
        ),
      ),
    );

    // Hiển thị key/QR sau khi tạo phòng
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chia sẻ phòng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Key phòng: $roomKey'),
            const SizedBox(height: 16),
            SizedBox(
              width: 180,
              height: 180,
              child: QrImageView(
                data: roomKey,
                version: QrVersions.auto,
                size: 180.0,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );

    // Optionally clear or navigate back
    _nameController.clear();
    _descController.clear();
    setState(() => _type = RoomType.open);
  }

  String _generateRoomKey(String name) {
    // Demo: key là 'room-' + tên phòng (thực tế nên dùng id hoặc mã hóa)
    return 'room-$name';
  }

  @override
  Widget build(BuildContext context) {
    final isCreateEnabled = _nameController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Room')),
      body: SafeArea(
        child: Padding(
          padding: _kPadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: _kRadius),
                elevation: 2,
                child: Padding(
                  padding: _kPadding,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Room Name',
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Room name is required'
                              : null,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descController,
                          decoration: const InputDecoration(
                            labelText: 'Description (optional)',
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Room Type',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<RoomType>(
                          segments: const [
                            ButtonSegment(
                              value: RoomType.open,
                              label: Text('Open'),
                            ),
                            ButtonSegment(
                              value: RoomType.invite,
                              label: Text('Invite'),
                            ),
                          ],
                          selected: <RoomType>{_type},
                          onSelectionChanged: (s) =>
                              setState(() => _type = s.first),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isCreateEnabled ? _createRoom : null,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Text('Create'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
