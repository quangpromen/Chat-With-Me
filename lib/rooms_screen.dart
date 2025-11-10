import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kPadding = EdgeInsets.all(16);
const _kRadius = BorderRadius.all(Radius.circular(18));

class RoomsScreen extends ConsumerStatefulWidget {
  const RoomsScreen({super.key});

  @override
  ConsumerState<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends ConsumerState<RoomsScreen> {
  // Use Riverpod roomsProvider

  void _showQrScanScreen(BuildContext context) async {
    final scannedKey = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quét QR để vào phòng'),
        content: const Text('Demo: Quét QR sẽ trả về key phòng'),

  void _joinRoomByKey(BuildContext context, String key) {
    final notifier = ref.read(appStateProvider.notifier);
    notifier.joinRoomByKey(key).then((result) {
      if (result != null) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Tham gia phòng thành công'),
            content: Text('Đã tham gia phòng: ${result.name}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Không tìm thấy phòng'),
            content: Text('Không tìm thấy phòng với key: $key trên mạng LAN'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      }
    });

  String _decodeRoomKey(String key) {
    if (key.startsWith('room-')) {
      return key.substring(5);
    }
    return key;

  Map<String, dynamic>? _findRoomOnLan(String roomId) {
    final rooms = ref.read(roomsProvider);
    for (final room in rooms) {
      if (room.id == roomId) {
        return {'name': room.name, 'id': room.id, 'members': room.members};
      }
    }
    return null;
  }
  }
}
  void _showQrScanScreen(BuildContext context) async {
    // TODO: Hiển thị màn hình quét QR, lấy kết quả và gọi joinRoomByKey
    // Giả lập kết quả quét QR
    final scannedKey = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quét QR để vào phòng'),
        content: const Text('Demo: Quét QR sẽ trả về key phòng'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('room-123456'),
            child: const Text('Quét xong'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
    if (scannedKey != null && scannedKey.isNotEmpty) {
      _joinRoomByKey(context, scannedKey);
    }
  }

  void _showEnterKeyDialog(BuildContext context) async {
    final keyController = TextEditingController();
    final enteredKey = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nhập key phòng'),
        content: TextField(
          controller: keyController,
          decoration: const InputDecoration(hintText: 'Nhập key phòng...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(keyController.text.trim()),
            child: const Text('Tham gia'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
    if (enteredKey != null && enteredKey.isNotEmpty) {
      _joinRoomByKey(context, enteredKey);
    }
  }

  void _joinRoomByKey(BuildContext context, String key) {
    final roomId = _decodeRoomKey(key);
    final foundRoom = _findRoomOnLan(roomId);
    if (foundRoom != null) {
      _syncJoinRoom(foundRoom);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Tham gia phòng thành công'),
          content: Text('Đã tham gia phòng: ${foundRoom['title']}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Không tìm thấy phòng'),
          content: Text('Không tìm thấy phòng với key: $key trên mạng LAN'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    }
  }
  

  String _decodeRoomKey(String key) {
    if (key.startsWith('room-')) {
      return key.substring(5);
    }
    return key;
  }

  Map<String, dynamic>? _findRoomOnLan(String roomId) {
    // Deprecated: now handled by AppNotifier.joinRoomByKey
    return null;
  }

  void _syncJoinRoom(Map<String, dynamic> room) {
    // TODO: Tích hợp với AppState và LAN sync để đồng bộ member
  }
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: const Icon(Icons.person),
            ),
          ),
          title: const Text('Rooms'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
              tooltip: 'Search rooms',
            ),
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () => _showQrScanScreen(context),
              tooltip: 'Quét QR để vào phòng',
            ),
            IconButton(
              icon: const Icon(Icons.vpn_key),
              onPressed: () => _showEnterKeyDialog(context),
              tooltip: 'Nhập key để vào phòng',
            ),
          ],
          elevation: 0,
        ),
        body: Padding(
          padding: _kPadding,
          child: ListView.separated(
            itemCount: rooms.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final room = rooms[index];
              return Material(
                color: Theme.of(context).cardColor,
                elevation: 2,
                borderRadius: _kRadius,
                child: InkWell(
                  borderRadius: _kRadius,
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(borderRadius: _kRadius),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.group),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                room.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                room.members.isNotEmpty
                                    ? 'Members: ${room.members.length}'
                                    : 'No members',
                                style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Optionally show unread badge if you track unread
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          tooltip: 'New Room',
          child: const Icon(Icons.add),
        ),
      );
    }
      floatingActionButton: FloatingActionButton(
