import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_exception.dart';
import '../../../domain/entities/doctor.dart';
import '../../providers/doctors_providers.dart';
import '../../widgets/app_error_view.dart';
import '../../widgets/doctor_avatar.dart';
import '../../widgets/favorite_button.dart';
import 'appointment_request_sheet.dart';

/// Full provider profile: photo header, key stats, about, education,
/// languages, weekly schedule, location — plus the appointment request
/// flow via [AppointmentRequestSheet].
class DoctorDetailScreen extends ConsumerWidget {
  const DoctorDetailScreen({super.key, required this.doctorId});

  final String doctorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorAsync = ref.watch(doctorDetailProvider(doctorId));
    final theme = Theme.of(context);

    return Scaffold(
      body: doctorAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
        error: (error, _) => AppErrorView(
          title: 'Provider unavailable',
          message: error is AppException
              ? error.userMessage
              : 'We could not load this provider.',
          onRetry: () => ref.invalidate(doctorDetailProvider(doctorId)),
        ),
        data: (doctor) => CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 232,
              title: Text(doctor.name),
              flexibleSpace: FlexibleSpaceBar(
                background: _Header(doctor: doctor),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _NameBlock(doctor: doctor),
                  const SizedBox(height: 16),
                  _StatsRow(doctor: doctor),
                  const SizedBox(height: 20),
                  _AboutCard(doctor: doctor),
                  if (doctor.sessions.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _SectionTitle(
                      icon: Icons.schedule,
                      title: 'Weekly schedule',
                    ),
                    const SizedBox(height: 8),
                    _ScheduleCard(doctor: doctor),
                  ],
                  if (doctor.education.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _SectionTitle(
                      icon: Icons.school_outlined,
                      title: 'Education',
                    ),
                    const SizedBox(height: 8),
                    _EducationCard(doctor: doctor),
                  ],
                  if (doctor.languages.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _SectionTitle(
                      icon: Icons.translate_outlined,
                      title: 'Languages',
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final language in doctor.languages)
                          Chip(
                            label: Text(language),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  _SectionTitle(
                    icon: Icons.location_on_outlined,
                    title: 'Clinic',
                  ),
                  const SizedBox(height: 8),
                  _LocationCard(doctor: doctor),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: doctorAsync.maybeWhen(
        data: (doctor) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                FavoriteButton(doctorId: doctor.id, doctorName: doctor.name),
                const SizedBox(width: 8),
                Expanded(
                  child: _RequestButton(doctor: doctor, theme: theme),
                ),
              ],
            ),
          ),
        ),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }
}

class _RequestButton extends StatelessWidget {
  const _RequestButton({required this.doctor, required this.theme});

  final Doctor doctor;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final accepting = doctor.isAcceptingNewPatients;
    return Semantics(
      button: true,
      label: accepting
          ? 'Request appointment with ${doctor.name}'
          : '${doctor.name} is not accepting new patients',
      child: FilledButton.icon(
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        onPressed: accepting
            ? () => showAppointmentRequestSheet(context, doctor)
            : null,
        icon: const Icon(Icons.event_available),
        label: Text(
          accepting ? 'Request appointment' : 'Not accepting patients',
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: theme.colorScheme.primaryContainer),
        Center(
          child: Hero(
            tag: 'doctor-avatar-${doctor.id}',
            child: DoctorAvatar(
              photoUrl: doctor.photoUrl,
              name: doctor.name,
              size: 112,
            ),
          ),
        ),
        // Decorative gradient so the pinned app bar stays readable.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.surface.withValues(alpha: 0.15),
                theme.colorScheme.surface.withValues(alpha: 0.45),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NameBlock extends StatelessWidget {
  const _NameBlock({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                doctor.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          doctor.specialtyName,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        // Wrap: the status badge drops to a second line on narrow phones
        // and large text scales instead of overflowing (the name block
        // sits next to the avatar, so width is at a premium here).
        Wrap(
          spacing: 12,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Semantics(
              label:
                  'Rated ${doctor.rating.toStringAsFixed(1)} out of 5 from '
                  '${doctor.reviewCount} reviews',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: 20,
                    color: Colors.amber.shade700,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '${doctor.rating.toStringAsFixed(1)} · ${doctor.reviewCount} reviews',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            if (!doctor.isAcceptingNewPatients)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Waitlist only', style: theme.textTheme.labelSmall),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Accepting patients',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    final next = doctor.nextAvailableAt != null
        ? DateFormat('d MMM', 'en_US').format(doctor.nextAvailableAt!)
        : '—';

    return Semantics(
      label:
          'Experience ${doctor.experienceYears} years, consultation fee '
          '${doctor.consultationFee.toStringAsFixed(0)} dollars, next '
          'available $next',
      child: Row(
        children: [
          Expanded(
            child: _Stat(
              icon: Icons.work_history_outlined,
              value: '${doctor.experienceYears} yrs',
              label: 'Experience',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _Stat(
              icon: Icons.payments_outlined,
              value: r'$' + doctor.consultationFee.toStringAsFixed(0),
              label: 'Consultation',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _Stat(
              icon: Icons.event_available,
              value: next,
              label: 'Next visit',
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              doctor.bio,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.4,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        child: Column(
          children: [
            for (final session in doctor.sessions)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 96,
                      child: Text(
                        session.day,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${session.from} – ${session.to}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EducationCard extends StatelessWidget {
  const _EducationCard({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (index, item) in doctor.education.indexed) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.verified_outlined,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(item, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
              if (index < doctor.education.length - 1)
                const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.location_on_outlined,
          color: theme.colorScheme.primary,
        ),
        title: Text(doctor.address),
        subtitle: Text(doctor.city),
      ),
    );
  }
}
