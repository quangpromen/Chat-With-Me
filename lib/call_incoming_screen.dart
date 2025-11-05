import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// CallIncomingScreen
// - Fullscreen with blurred background
// - Avatar, caller name
// - Two large buttons: Accept (green), Decline (red)
// - Modern centered layout

class CallIncomingScreen extends ConsumerWidget {
  const CallIncomingScreen({
    super.key,
    required this.callerName,
    this.avatarTag = 'avatar-hero',
  });

  final String callerName;
  final String avatarTag;

  // Route suggestion: '/call_incoming'

  void _acceptCall(BuildContext context) {
    // Placeholder: accept call behavior
    Navigator.of(context).maybePop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Call accepted (placeholder)')),
    );
  }

  void _declineCall(BuildContext context) {
    // Placeholder: decline call behavior
    Navigator.of(context).maybePop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Call declined (placeholder)')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background with blur effect
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withAlpha((0.6 * 255).round()),
                  Theme.of(context).colorScheme.secondaryContainer.withAlpha(
                    (0.8 * 255).round(),
                  ),
                ],
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withAlpha((0.2 * 255).round()),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top section: Caller info
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Hero(
                          tag: avatarTag,
                          child: CircleAvatar(
                            radius: 72,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            child: Text(
                              callerName.isNotEmpty
                                  ? callerName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          callerName,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Incoming call...',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white.withAlpha(
                                  (0.9 * 255).round(),
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom section: Action buttons
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Decline button
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Material(
                            color: Colors.red.shade600,
                            shape: const CircleBorder(),
                            elevation: 8,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => _declineCall(context),
                              child: const Padding(
                                padding: EdgeInsets.all(28.0),
                                child: Icon(
                                  Icons.call_end,
                                  size: 36,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Decline',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),

                      // Accept button
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Material(
                            color: Colors.green.shade600,
                            shape: const CircleBorder(),
                            elevation: 8,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => _acceptCall(context),
                              child: const Padding(
                                padding: EdgeInsets.all(28.0),
                                child: Icon(
                                  Icons.call,
                                  size: 36,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Accept',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
