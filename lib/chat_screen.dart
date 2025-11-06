import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ChatScreen
// - ListView of message bubbles (left/right alignment)
// - Input composer with TextField, attach button, send button
// - Connection status banner (Connected / Reconnecting)
// - Each message bubble shows: sender name, time, ticks (sent/delivered/read)
// - Uses Hero animation for the avatar when entering chat

const _kPadding = EdgeInsets.all(16);

class ChatMessage {
  ChatMessage({
    required this.sender,
    required this.text,
    required this.time,
    this.isMe = false,
  });
  final String sender;
  final String text;
  final DateTime time;
  final bool isMe;
  // placeholder status: 0=sent,1=delivered,2=read
  int status = 0;
}

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  // Route suggestion: '/chat'
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final List<ChatMessage> _messages = List.generate(
    8,
    (i) => ChatMessage(
      sender: i.isEven ? 'Alice' : 'You',
      text: i.isEven ? 'Hello from Alice (#$i)' : 'Reply message (#$i)',
      time: DateTime.now().subtract(Duration(minutes: i * 5)),
      isMe: i.isOdd,
    ),
  );

  final TextEditingController _controller = TextEditingController();
  final bool _reconnecting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final msg = ChatMessage(
      sender: 'You',
      text: text,
      time: DateTime.now(),
      isMe: true,
    )..status = 0;
    setState(() {
      _messages.insert(0, msg);
      _controller.clear();
    });
    // simulate delivery/read
    Future.delayed(const Duration(seconds: 1), () {
      setState(() => msg.status = 1);
    });
    Future.delayed(const Duration(seconds: 3), () {
      setState(() => msg.status = 2);
    });
  }

  Widget _buildBanner() {
    if (_reconnecting) {
      return _ConnectionBanner(
        text: 'Reconnecting...',
        color: Colors.orange,
        icon: Icons.sync,
      );
    }
    return _ConnectionBanner(
      text: 'Connected',
      color: Colors.green,
      icon: Icons.check_circle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Hero(
          tag: 'avatar-hero',
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: const Icon(Icons.person),
            ),
          ),
        ),
        title: const Text('Chat'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: _buildBanner(),
          ),
          Expanded(
            child: Padding(
              padding: _kPadding,
              child: ListView.builder(
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Align(
                      alignment: msg.isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        child: _MessageBubble(message: msg),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Composer
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.attach_file),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      minLines: 1,
                      maxLines: 4,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    onPressed: _sendMessage, // child argument last
                    mini: true,
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
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

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Widget _buildTicks(int status) {
    // 0 = sent (one tick), 1 = delivered (two ticks), 2 = read (two blue ticks)
    if (status == 0) return const Icon(Icons.check, size: 14);
    if (status == 1) return const Icon(Icons.done_all, size: 14);
    return Icon(Icons.done_all, size: 14, color: Colors.blue.shade400);
  }

  @override
  Widget build(BuildContext context) {
    final bg = message.isMe
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).cardColor;
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.04 * 255).round()),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.sender,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message.text,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTime(message.time),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  _buildTicks(message.status),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConnectionBanner extends StatelessWidget {
  const _ConnectionBanner({
    required this.text,
    required this.color,
    required this.icon,
  });
  final String text;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha((0.12 * 255).round()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
