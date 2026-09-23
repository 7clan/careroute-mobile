import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../providers/session_providers.dart';
import '../../widgets/app_error_view.dart';

/// First frame of the app: while the stored session is being restored the
/// router parks here. Restore failures (e.g. no network) surface a retry
/// rather than silently dropping the user at the login screen.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: switch (session) {
        AsyncError(:final error) => AppErrorView(
          title: 'Could not restore your session',
          message: error is AppException
              ? error.userMessage
              : 'Something went wrong while signing you in.',
          onRetry: () => ref.invalidate(sessionProvider),
        ),
        _ => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.health_and_safety_outlined,
                  size: 56,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'CareRoute',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(strokeWidth: 2.5),
            ],
          ),
        ),
      },
    );
  }
}
