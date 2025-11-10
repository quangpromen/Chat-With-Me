import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'screens/onboarding_screen.dart';
import 'providers/app_state.dart';
import 'screens/permissions_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/discovery_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/peers_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/host_dashboard_screen.dart';
import 'screens/diagnostics_screen.dart';
import 'screens/invite_screen.dart';
import 'screens/key_verification_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/file_transfer_screen.dart';
import 'screens/call_outgoing_screen.dart';
import 'screens/call_incoming_screen.dart';
import 'screens/call_ongoing_screen.dart';
import 'screens/manual_host_screen.dart';

void main() {
  runApp(const ProviderScope(child: LanChatApp()));
}

final _router = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(
      path: '/permissions',
      builder: (_, __) => const PermissionsScreen(),
    ),
    GoRoute(
      path: '/profile-setup',
      builder: (_, __) => const ProfileSetupScreen(),
    ),
    GoRoute(path: '/discovery', builder: (_, __) => const DiscoveryScreen()),
    GoRoute(path: '/manual-host', builder: (_, __) => const ManualHostScreen()),
    GoRoute(
      path: '/chat',
      builder: (context, state) => ChatScreen(
        peerId:
            state.extra != null &&
                (state.extra as Map<String, dynamic>)['peerId'] != null
            ? (state.extra as Map<String, dynamic>)['peerId']
            : '',
        peerIp:
            state.extra != null &&
                (state.extra as Map<String, dynamic>)['peerIp'] != null
            ? (state.extra as Map<String, dynamic>)['peerIp']
            : '',
      ),
    ),
    GoRoute(
      path: '/transfer/:fileId',
      builder: (context, state) =>
          FileTransferScreen(fileId: state.pathParameters['fileId'] ?? 'file'),
    ),
    GoRoute(
      path: '/call/outgoing',
      builder: (_, __) => const CallOutgoingScreen(),
    ),
    GoRoute(
      path: '/call/incoming',
      builder: (_, __) => const CallIncomingScreen(),
    ),
    GoRoute(
      path: '/call/ongoing',
      builder: (_, __) => const CallOngoingScreen(),
    ),
    GoRoute(path: '/peers', builder: (_, __) => const PeersScreen()),
    GoRoute(path: '/invite', builder: (_, __) => const InviteScreen()),
    GoRoute(
      path: '/keys/verify',
      builder: (_, __) => const KeyVerificationScreen(),
    ),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    GoRoute(path: '/host', builder: (_, __) => const HostDashboardScreen()),
    GoRoute(
      path: '/diagnostics',
      builder: (_, __) => const DiagnosticsScreen(),
    ),
  ],
  redirect: (context, state) {
    // Use Riverpod to read the app state
    final container = ProviderScope.containerOf(context, listen: false);
    final appState = container.read(appStateProvider);

    // If onboarding not complete, always go to onboarding
    if (!appState.onboardingComplete) {
      return state.fullPath == '/onboarding' ? null : '/onboarding';
    }
    // If not all permissions granted, go to permissions
    if (!appState.hasAllPermissions) {
      return state.fullPath == '/permissions' ? null : '/permissions';
    }
    // If profile not set, go to profile setup
    if (appState.profile == null) {
      return state.fullPath == '/profile-setup' ? null : '/profile-setup';
    }
    // If already completed all, skip onboarding flow
    if (state.fullPath == '/onboarding' ||
        state.fullPath == '/permissions' ||
        state.fullPath == '/profile-setup') {
      return '/discovery';
    }
    return null;
  },
);

class LanChatApp extends StatelessWidget {
  const LanChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LanChat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
      ),
      routerConfig: _router,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
