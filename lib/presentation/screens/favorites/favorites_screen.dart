import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../providers/favorites_providers.dart';
import '../../widgets/app_empty_view.dart';
import '../../widgets/app_error_view.dart';
import '../../widgets/doctor_card.dart';
import '../../widgets/skeleton_tile.dart';

/// Saved providers. The set of ids is persisted locally; the full provider
/// data is fetched through the API (see docs/PERFORMANCE.md for the
/// trade-off discussion).
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteDoctorsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Saved providers')),
      body: SafeArea(
        top: false,
        child: favorites.when(
          data: (doctors) {
            if (doctors.isEmpty) {
              return AppEmptyView(
                icon: Icons.favorite_border,
                title: 'No saved providers yet',
                message:
                    'Tap the heart on any provider to keep them here for '
                    'quick access.',
                actionLabel: 'Discover providers',
                onAction: () => context.go('/home'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.only(top: 4, bottom: 16),
              itemCount: doctors.length,
              itemBuilder: (context, index) => DoctorCard(
                doctor: doctors[index],
                onTap: () => context.go('/doctors/${doctors[index].id}'),
              ),
            );
          },
          loading: () => const DoctorListSkeleton(count: 3),
          error: (error, _) => AppErrorView(
            message: error is AppException ? error.userMessage : 'Failed.',
            onRetry: () => ref.invalidate(favoriteDoctorsProvider),
          ),
        ),
      ),
    );
  }
}
