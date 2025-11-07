import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../providers/app_state.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.roomId});

  final String roomId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  Future<void> _pickAndSendFile() async {
    // Chọn ảnh từ gallery
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Gửi tin nhắn kiểu ảnh
      ref
          .read(appStateProvider.notifier)
          .sendMessage(widget.roomId, '[image]${pickedFile.path}');
    }
  }

  bool _showEmojiPicker = false;
  late final TextEditingController _controller;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }
    ref.read(appStateProvider.notifier).sendMessage(widget.roomId, text);
    _controller.clear();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final room = ref.watch(roomByIdProvider(widget.roomId));
    final messages = ref.watch(messagesByRoomProvider(widget.roomId));
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      appBar: AppBar(
        title: Text(room?.name ?? 'Chat'),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? _EmptyChatPlaceholder(roomName: room?.name)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return _MessageBubble(message: message);
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  tooltip: 'Attach file or image',
                  onPressed: _pickAndSendFile,
                ),
                IconButton(
                  icon: const Icon(Icons.emoji_emotions_outlined),
                  tooltip: 'Insert emoji',
                  onPressed: () {
                    setState(() {
                      _showEmojiPicker = !_showEmojiPicker;
                    });
                  },
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: const CircleBorder(),
                  ),
                  onPressed: _sendMessage,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
          if (_showEmojiPicker)
            SizedBox(
              height: 280,
              child: EmojiPicker(
                onEmojiSelected: (category, emoji) {
                  _controller.text += emoji.emoji;
                  _controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: _controller.text.length),
                  );
                },
                textEditingController: _controller,
              ),
            ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isMe = message.fromCurrentUser;
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isMe
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.surfaceContainerHighest;
    final textColor = isMe
        ? Theme.of(context).colorScheme.onPrimaryContainer
        : Theme.of(context).colorScheme.onSurfaceVariant;

    final isImage = message.text.startsWith('[image]');
    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                // TODO: Hiển thị trang profile của người gửi
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProfileScreenView(name: message.senderName),
                  ),
                );
              },
              child: Text(
                message.senderName,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: textColor.withOpacity(0.7),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 4),
            if (isImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(message.text.replaceFirst('[image]', '')),
                  width: 180,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              )
            else
              Text(
                message.text,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: textColor),
              ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreenView extends StatelessWidget {
  final String name;
  const ProfileScreenView({required this.name, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile: $name')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 48,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(height: 16),
            Text(name, style: Theme.of(context).textTheme.headlineSmall),
            // TODO: Hiển thị thêm thông tin nếu có (avatar, deviceId, ...)
          ],
        ),
      ),
    );
  }
}

class _EmptyChatPlaceholder extends StatelessWidget {
  const _EmptyChatPlaceholder({this.roomName});

  final String? roomName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            roomName != null ? 'No messages in $roomName yet' : 'No messages',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text('Say hello to start the conversation.'),
        ],
      ),
    );
  }
}
