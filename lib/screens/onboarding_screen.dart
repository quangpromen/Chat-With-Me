import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_state.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slides = [
      {
        'icon': Icons.wifi,
        'title': 'Offline LAN Chat',
        'desc': 'Chat with peers on your local network.',
      },
      {
        'icon': Icons.message,
        'title': 'Messages & Files',
        'desc': 'Send messages and share files easily.',
      },
      {
        'icon': Icons.call,
        'title': 'Voice Call',
        'desc': 'Make voice calls over LAN.',
      },
    ];
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  itemCount: slides.length,
                  itemBuilder: (context, i) => Padding(
                    padding: const EdgeInsets.all(32),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.indigo[100],
                              child: Icon(
                                slides[i]['icon'] as IconData,
                                size: 48,
                                color: Colors.indigo,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              slides[i]['title'] as String,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              slides[i]['desc'] as String,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Get Started'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    ref.read(appStateProvider.notifier).completeOnboarding();
                    context.go('/permissions');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
