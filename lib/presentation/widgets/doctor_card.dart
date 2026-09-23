import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/doctor.dart';
import 'doctor_avatar.dart';
import 'favorite_button.dart';

/// Provider card used by the discovery feed and the favorites screen.
///
/// The whole card is one semantic node: screen readers announce the
/// provider, specialty, rating and location in one gesture instead of
/// node-by-node noise.
class DoctorCard extends StatelessWidget {
  const DoctorCard({super.key, required this.doctor, required this.onTap});

  final Doctor doctor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nextAvailable = doctor.nextAvailableAt != null
        ? DateFormat('EEE, d MMM').format(doctor.nextAvailableAt!)
        : null;

    final ratingColor = switch (doctor.rating) {
      >= 4.5 => Colors.amber.shade700,
      >= 4.0 => Colors.amber.shade600,
      _ => Colors.grey,
    };

    return Semantics(
      button: true,
      label:
          '${doctor.name}, ${doctor.specialtyName}, rating ${doctor.rating.toStringAsFixed(1)} out of 5, ${doctor.city}',
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'doctor-avatar-${doctor.id}',
                  child: DoctorAvatar(
                    photoUrl: doctor.photoUrl,
                    name: doctor.name,
                    size: 64,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style: theme.textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        doctor.specialtyName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          Semantics(
                            label:
                                'Rated ${doctor.rating.toStringAsFixed(1)} '
                                'out of 5 from ${doctor.reviewCount} reviews',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 18,
                                  color: ratingColor,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  doctor.rating.toStringAsFixed(1),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  ' (${doctor.reviewCount})',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconTheme(
                            data: IconThemeData(
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on_outlined),
                                const SizedBox(width: 3),
                                Text(
                                  doctor.city,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.payments_outlined,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '\$${doctor.consultationFee.toStringAsFixed(0)} '
                            'consultation',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (nextAvailable != null) ...[
                            const SizedBox(width: 12),
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.event_available,
                                    size: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      'Next: $nextAvailable',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                FavoriteButton(doctorId: doctor.id, doctorName: doctor.name),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
