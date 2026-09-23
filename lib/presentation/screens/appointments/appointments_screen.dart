import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_exception.dart';
import '../../../domain/entities/appointment.dart';
import '../../providers/appointments_providers.dart';
import '../../widgets/app_empty_view.dart';
import '../../widgets/app_error_view.dart';
import '../../widgets/skeleton_tile.dart';

/// Appointment requests: upcoming & past sections, status badges and
/// cancellation with confirmation.
class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointments = ref.watch(appointmentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Appointments')),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () => ref.read(appointmentsProvider.notifier).refresh(),
          child: appointments.when(
            skipLoadingOnRefresh: true,
            data: (items) {
              if (items.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 80),
                    AppEmptyView(
                      icon: Icons.event_busy,
                      title: 'No appointments yet',
                      message:
                          'When you request an appointment it will show up '
                          'here with its status.',
                      actionLabel: 'Find a provider',
                      onAction: () => context.go('/home'),
                    ),
                  ],
                );
              }
              final upcoming = ref.watch(upcomingAppointmentsProvider);
              final past = items
                  .where((a) => !upcoming.contains(a))
                  .toList(growable: false);
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  if (upcoming.isNotEmpty) ...[
                    _SectionHeader('Upcoming', count: upcoming.length),
                    for (final appointment in upcoming)
                      _AppointmentTile(appointment: appointment),
                  ],
                  if (past.isNotEmpty) ...[
                    _SectionHeader('Past & cancelled', count: past.length),
                    for (final appointment in past)
                      _AppointmentTile(appointment: appointment),
                  ],
                ],
              );
            },
            error: (error, _) => AppErrorView(
              message: error is AppException ? error.userMessage : 'Failed.',
              onRetry: () => ref.invalidate(appointmentsProvider),
            ),
            loading: () => const DoctorListSkeleton(count: 3),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title, {required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        '$title ($count)',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _AppointmentTile extends ConsumerWidget {
  const _AppointmentTile({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final canCancel = appointment.status == AppointmentStatus.pending;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _DateBadge(date: appointment.date),
        title: Text(
          appointment.doctorName,
          style: theme.textTheme.titleSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text('${appointment.specialtyName} · ${appointment.time}'),
            if (appointment.reason != null &&
                appointment.reason!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                appointment.reason!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        isThreeLine:
            appointment.reason != null && appointment.reason!.isNotEmpty,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatusBadge(status: appointment.status),
            if (canCancel)
              Semantics(
                label: 'Cancel appointment with ${appointment.doctorName}',
                button: true,
                child: IconButton(
                  tooltip: 'Cancel appointment',
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => _confirmCancel(context, ref),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel appointment?'),
        content: Text(
          'Your request with ${appointment.doctorName} on '
          '${DateFormat('d MMMM').format(appointment.date)} at '
          '${appointment.time} will be cancelled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel appointment'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(appointmentsProvider.notifier).cancel(appointment.id);
    } on AppException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.userMessage)));
      }
    }
  }
}

class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: DateFormat('EEEE d MMMM').format(date),
      child: Container(
        width: 52,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('MMM').format(date).toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${date.day}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final AppointmentStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, color, onColor) = switch (status) {
      AppointmentStatus.pending => (
        'Pending',
        Colors.amber.shade100,
        Colors.brown.shade800,
      ),
      AppointmentStatus.confirmed => (
        'Confirmed',
        Colors.green.shade100,
        Colors.green.shade900,
      ),
      AppointmentStatus.cancelled => (
        'Cancelled',
        theme.colorScheme.surfaceContainerHighest,
        theme.colorScheme.onSurfaceVariant,
      ),
    };
    return Semantics(
      label: 'Status: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: onColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
