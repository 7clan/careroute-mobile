import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../providers/favorites_providers.dart';

/// Favorite toggle used on provider cards and the detail screen.
///
/// Performance: watches [isFavoriteProvider] (a per-doctor derived
/// provider), so a toggle rebuilds only this button — never the list.
/// The button is 48×48 dp (accessible touch target) and announces its
/// state to screen readers.
class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({
    super.key,
    required this.doctorName,
    required this.doctorId,
  });

  final String doctorId;
  final String doctorName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(isFavoriteProvider(doctorId));
    final theme = Theme.of(context);

    return Semantics(
      label: isFavorite
          ? 'Remove $doctorName from favorites'
          : 'Save $doctorName to favorites',
      button: true,
      child: IconButton(
        tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
        onPressed: () => _toggle(context, ref),
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? theme.colorScheme.error : null,
        ),
      ),
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(favoritesProvider.notifier);
    try {
      await controller.toggle(doctorId);
    } on AppException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.userMessage)));
      }
    }
  }
}
