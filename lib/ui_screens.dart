import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// NOTE: This file provides three Riverpod-compatible, Material-3 UI screens.
// Each screen is a standalone ConsumerWidget (which extends StatelessWidget)
// and follows project UI rules: rounded corners, consistent padding,
// AppBar with actions, responsive layout, and placeholder content only.

// Usage:
// - Ensure `flutter_riverpod` is added to `pubspec.yaml`:
//     flutter pub add flutter_riverpod
// - Wrap your app with ProviderScope and register named routes:
//   void main() => runApp(ProviderScope(child: MyApp()));
//   class MyApp extends StatelessWidget { ... MaterialApp(routes: {
//     '/chat': (c) => const ChatScreen(),
//     '/discovery': (c) => const DiscoveryScreen(),
//     '/settings': (c) => const SettingsScreen(),
//   }) ... }

const _kPadding = EdgeInsets.all(16);
const _kRadius = BorderRadius.all(Radius.circular(18));

// -----------------------------
// /chat
// -----------------------------
class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  // Route name example: '/chat'
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {}, // placeholder for search action
            tooltip: 'Search chats',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
            tooltip: 'More',
          ),
        ],
      ),
      body: Padding(
        padding: _kPadding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive: use a compact list on narrow screens, two-column on wide
            final isTablet = constraints.maxWidth >= 700;
            return isTablet
                ? Row(
                    children: [
                      // left: conversations list
                      Flexible(flex: 2, child: _ConversationsList()),
                      const SizedBox(width: 16),
                      // right: selected conversation / placeholder
                      Flexible(
                        flex: 3,
                        child: _ConversationDetailPlaceholder(),
                      ),
                    ],
                  )
                : const _ConversationsList();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // child argument last
        onPressed: () {
          // Placeholder: open new chat
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            builder: (_) => const _NewChatBottomSheet(),
          );
        },
        child: const Icon(Icons.chat),
      ),
    );
  }
}

class _ConversationsList extends StatelessWidget {
  const _ConversationsList();

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: _kRadius),
      child: ListView.separated(
        padding: _kPadding,
        itemBuilder: (context, index) => ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ), // avatar placeholder
          title: Text('Contact #$index'),
          subtitle: const Text('Last message preview goes here'),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('12:34'),
              SizedBox(height: 4),
              Icon(Icons.circle, size: 10),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onTap: () {}, // placeholder: open conversation
        ),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemCount: 12,
      ),
    );
  }
}

class _ConversationDetailPlaceholder extends StatelessWidget {
  const _ConversationDetailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: _kRadius),
      child: Padding(
        padding: _kPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            CircleAvatar(radius: 28, child: Icon(Icons.person, size: 28)),
            SizedBox(height: 12),
            Text(
              'Select a conversation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text('Messages will appear here when a conversation is selected.'),
          ],
        ),
      ),
    );
  }
}

class _NewChatBottomSheet extends StatelessWidget {
  const _NewChatBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          const ListTile(
            leading: CircleAvatar(child: Icon(Icons.person_add)),
            title: Text('Start a new chat'),
            subtitle: Text('Select a contact to begin'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.person_add),
            label: const Text('Create'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// -----------------------------
// /discovery
// -----------------------------
class DiscoveryScreen extends ConsumerWidget {
  const DiscoveryScreen({super.key});

  // Route name example: '/discovery'
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discovery'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Padding(
        padding: _kPadding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;
            // Use GridView for discovery items; responsive column count
            final crossAxisCount = isWide ? 3 : 2;
            return Card(
              shape: RoundedRectangleBorder(borderRadius: _kRadius),
              child: GridView.builder(
                padding: _kPadding,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: 12,
                itemBuilder: (context, index) => _DiscoveryTile(index: index),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DiscoveryTile extends StatelessWidget {
  const _DiscoveryTile({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: _kRadius,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: const Center(
                  child: Icon(Icons.image, size: 48),
                ), // image placeholder
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Item #$index',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Short description goes here',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------
// /settings
// -----------------------------
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  // Route name example: '/settings'
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help',
          ),
        ],
      ),
      body: Padding(
        padding: _kPadding,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: _kRadius),
          child: ListView(
            padding: _kPadding,
            children: [
              // Account section
              const Text(
                'Account',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: const Text('Profile'),
                subtitle: const Text('Edit profile details'),
                onTap: () {},
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const Divider(),
              // Appearance section
              const Text(
                'Appearance',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (_) {}, // placeholder: toggle theme
                title: const Text('Dark mode'),
                subtitle: const Text('Switch between light and dark themes'),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.color_lens),
                title: const Text('Theme accent'),
                onTap: () {},
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                    ),
                    builder: (_) => Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text('Settings action sheet placeholder'),
                        ],
                      ),
                    ),
                  );
                }, // child argument last
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Open actions'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
