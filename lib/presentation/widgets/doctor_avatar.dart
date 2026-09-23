import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Provider photo with memory-optimized decoding and a graceful fallback
/// to the provider's initials (offline-safe, never broken images).
class DoctorAvatar extends StatelessWidget {
  const DoctorAvatar({
    super.key,
    required this.photoUrl,
    required this.name,
    this.size = 64,
    this.heroTag,
  });

  final String photoUrl;
  final String name;
  final double size;
  final String? heroTag;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fallback = CircleAvatar(
      radius: size / 2,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        _initials,
        style: TextStyle(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
          fontSize: size / 2.8,
        ),
      ),
    );

    final image = CircleAvatar(
      radius: size / 2,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      child: ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          // Downsamples to ~2x the display size — keeps the memory cache
          // small no matter what the source resolution is.
          child: CachedNetworkImage(
            imageUrl: photoUrl,
            memCacheWidth: (size * 2).round(),
            fadeInDuration: const Duration(milliseconds: 180),
            fit: BoxFit.cover,
            placeholder: (_, _) => fallback,
            errorWidget: (_, _, _) => fallback,
          ),
        ),
      ),
    );

    if (heroTag != null) {
      return Hero(tag: heroTag!, child: image);
    }
    return image;
  }
}
