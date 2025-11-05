import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Note: replaced external SmoothPageIndicator with a small internal indicator

// OnboardingScreen
// - PageView with 3 slides: Offline LAN Chat, Send Messages and Files, Voice Call in Local Network
// - SmoothPageIndicator and a "Get Started" button at the bottom
// - Material 3 friendly, responsive, rounded images/icons, consistent padding
// Notes:
// - Requires `flutter_riverpod` and `smooth_page_indicator` packages. Add them with:
//     flutter pub add flutter_riverpod
//     flutter pub add smooth_page_indicator
// - To wire: register route '/onboarding' in MaterialApp and wrap app with ProviderScope.

const _kPadding = EdgeInsets.all(16);
const _kRadius = BorderRadius.all(Radius.circular(18));

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  // Route name example: '/onboarding'
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final page = (_controller.hasClients && _controller.page != null)
          ? _controller.page!.round()
          : 0;
      if (page != _currentPage) {
        setState(() => _currentPage = page);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        actions: [
          IconButton(
            icon: const Icon(Icons.skip_next),
            onPressed: () {
              // Placeholder: skip action
              // In real app, navigate to main route
            },
            tooltip: 'Skip',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: _kPadding,
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isTablet = constraints.maxWidth >= 700;
                    return PageView(
                      controller: _controller,
                      children: [
                        _OnboardingPage(
                          title: 'Offline LAN Chat',
                          description:
                              'Chat with nearby devices over a local network without internet access.',
                          icon:
                              Icons.wifi_tethering, // illustration placeholder
                          isTablet: isTablet,
                        ),
                        _OnboardingPage(
                          title: 'Send Messages and Files',
                          description:
                              'Quickly share text, images and files with peers on the same network.',
                          icon: Icons.attach_file,
                          isTablet: isTablet,
                        ),
                        _OnboardingPage(
                          title: 'Voice Call in Local Network',
                          description:
                              'Make secure voice calls across devices connected to your LAN.',
                          icon: Icons.call,
                          isTablet: isTablet,
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Indicator + button row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (i) {
                          final isActive = i == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: isActive ? 12 : 8,
                            height: isActive ? 12 : 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        // Placeholder: normally navigate to main app
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                      child: const Text('Get Started'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    this.isTablet = false,
    // Removed unused key parameter
  });

  final String title;
  final String description;
  final IconData icon;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: isTablet ? 260 : 220,
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Center(
          child: Icon(
            icon,
            size: isTablet ? 96 : 72,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(description, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );

    return Card(
      shape: RoundedRectangleBorder(borderRadius: _kRadius),
      child: Padding(
        padding: _kPadding,
        child: isTablet
            ? Row(
                children: [
                  Expanded(child: image),
                  const SizedBox(width: 24),
                  Expanded(child: content),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [image, const SizedBox(height: 12), content],
              ),
      ),
    );
  }
}
