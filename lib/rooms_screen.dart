import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// RoomsScreen
// - AppBar with user avatar and search icon
// - ListView of rooms (title, last message, unread badge)
// - FloatingActionButton “New Room”
// - ListTile with rounded corners and subtle shadow

const _kPadding = EdgeInsets.all(16);
const _kRadius = BorderRadius.all(Radius.circular(18));

class RoomsScreen extends ConsumerStatefulWidget {
  const RoomsScreen({super.key});

  // Route suggestion: '/rooms'
  @override
  ConsumerState<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends ConsumerState<RoomsScreen> {
  // Placeholder room data
  final List<Map<String, dynamic>> _rooms = List.generate(
    12,
    (i) => {
      'title': 'Room ${i + 1}',
      'last': 'Last message preview for room ${i + 1}',
      'unread': i % 3 == 0 ? (i + 1) : 0,
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            onPressed: () {}, // placeholder for search action
            tooltip: 'Search rooms',
          ),
        ],
        elevation: 0,
      ),
      body: Padding(
        padding: _kPadding,
        child: ListView.separated(
          itemCount: _rooms.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final room = _rooms[index];
            return Material(
              color: Theme.of(context).cardColor,
              elevation: 2,
              borderRadius: _kRadius,
              child: InkWell(
                borderRadius: _kRadius,
                onTap: () {}, // placeholder: open room
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
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.group),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              room['title'],
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              room['last'],
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      if ((room['unread'] as int) > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${room['unread']}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // child argument last
        tooltip: 'New Room', // placeholder: create new room
        child: const Icon(Icons.add),
      ),
    );
  }
}
