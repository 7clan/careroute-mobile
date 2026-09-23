import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/appointment.dart';
import '../../../domain/entities/availability.dart';
import '../../../domain/entities/doctor.dart';
import '../../providers/appointments_providers.dart';
import '../../providers/doctors_providers.dart';

/// Opens the appointment request flow as a modal bottom sheet.
void showAppointmentRequestSheet(BuildContext context, Doctor doctor) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: AppointmentRequestSheet(doctor: doctor),
    ),
  );
}

/// Step-by-step appointment request:
/// 1. pick a bookable day (loaded from the availability API),
/// 2. pick a slot,
/// 3. optionally add a reason,
/// 4. submit — server-side validation errors (e.g. slot just taken) render
///    inline; success shows a confirmation state.
class AppointmentRequestSheet extends ConsumerStatefulWidget {
  const AppointmentRequestSheet({super.key, required this.doctor});

  final Doctor doctor;

  @override
  ConsumerState<AppointmentRequestSheet> createState() =>
      _AppointmentRequestSheetState();
}

class _AppointmentRequestSheetState
    extends ConsumerState<AppointmentRequestSheet> {
  AvailabilityDay? _selectedDay;
  String? _selectedSlot;
  final _reasonController = TextEditingController();

  bool _submitting = false;
  String? _formError;
  Map<String, List<String>> _fieldErrors = {};
  Appointment? _submitted;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _formError = null;
      _fieldErrors = {};
    });
    if (_selectedDay == null || _selectedSlot == null) {
      setState(
        () => _fieldErrors = {
          'date': _selectedDay == null ? ['Choose a day first.'] : [],
          'time': _selectedSlot == null ? ['Choose a time slot.'] : [],
        },
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final appointment = await ref
          .read(appointmentsProvider.notifier)
          .request(
            doctorId: widget.doctor.id,
            date: _selectedDay!.date,
            time: _selectedSlot!,
            reason: _reasonController.text.trim(),
          );
      setState(() => _submitted = appointment);
    } on ValidationException catch (error) {
      setState(() => _fieldErrors = error.fieldErrors);
    } on AppException catch (error) {
      setState(() => _formError = error.userMessage);
    } catch (error) {
      setState(() => _formError = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_submitted != null) {
      return _SuccessView(appointment: _submitted!);
    }

    final availability = ref.watch(availabilityProvider(widget.doctor.id));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Request appointment',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.doctor.name} · ${widget.doctor.specialtyName}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Choose a day',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (_fieldErrors['date']?.isNotEmpty ?? false) ...[
            const SizedBox(height: 6),
            Text(
              _fieldErrors['date']!.first,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ],
          const SizedBox(height: 10),
          availability.when(
            loading: () => const SizedBox(
              height: 88,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
            ),
            error: (error, _) => _AvailabilityError(
              doctorId: widget.doctor.id,
              message: error is AppException ? error.userMessage : 'Failed.',
            ),
            data: (days) {
              final bookable = days
                  .where((day) => day.slots.isNotEmpty)
                  .toList();
              if (bookable.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('No bookable days in the next three weeks.'),
                );
              }
              _selectedDay ??= bookable.first;
              return SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: bookable.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final day = bookable[index];
                    final selected = _selectedDay?.date == day.date;
                    return _DayChip(
                      day: day,
                      selected: selected,
                      onTap: () => setState(() {
                        _selectedDay = day;
                        // Reset the slot — different day, different slots.
                        _selectedSlot = null;
                        _fieldErrors = {};
                      }),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Available times',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (_fieldErrors['time']?.isNotEmpty ?? false) ...[
            const SizedBox(height: 6),
            Text(
              _fieldErrors['time']!.first,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ],
          const SizedBox(height: 10),
          if (_selectedDay != null)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final slot in _selectedDay!.slots)
                  Semantics(
                    label:
                        'Select $slot on '
                        '${DateFormat('EEEE, d MMMM').format(_selectedDay!.date)}',
                    button: true,
                    selected: _selectedSlot == slot,
                    child: ChoiceChip(
                      label: Text(slot),
                      selected: _selectedSlot == slot,
                      onSelected: (_) => setState(() {
                        _selectedSlot = slot;
                        _fieldErrors = {};
                      }),
                    ),
                  ),
              ],
            )
          else
            Text(
              'Pick a day to see times.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _reasonController,
            maxLines: 3,
            maxLength: 400,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              labelText: 'Reason (optional)',
              hintText: 'Briefly describe why you want the visit',
              alignLabelWithHint: true,
              prefixIcon: Padding(
                padding: EdgeInsets.only(top: 12, left: 12, right: 8),
                child: Icon(Icons.notes_outlined),
              ),
            ),
            validator: Validators.reason,
          ),
          if (_formError != null) ...[
            const SizedBox(height: 12),
            Semantics(
              liveRegion: true,
              child: Text(
                _formError!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Text('Request appointment'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final AvailabilityDay day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label:
          '${DateFormat('EEEE d MMMM').format(day.date)}, '
          '${day.slots.length} slots available',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 72,
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('EEE').format(day.date),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: selected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${day.date.day}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
              ),
              Text(
                DateFormat('MMM').format(day.date),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: selected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvailabilityError extends ConsumerWidget {
  const _AvailabilityError({required this.doctorId, required this.message});

  final String doctorId;
  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Text(message, textAlign: TextAlign.center),
        TextButton.icon(
          onPressed: () => ref.invalidate(availabilityProvider(doctorId)),
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 44,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Request sent',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your appointment with ${appointment.doctorName} on '
            '${DateFormat('EEEE, d MMMM').format(appointment.date)} at '
            '${appointment.time} is pending confirmation.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}
