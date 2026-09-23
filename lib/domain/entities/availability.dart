import 'package:freezed_annotation/freezed_annotation.dart';

part 'availability.freezed.dart';

/// A concrete calendar day on which a provider can be booked,
/// together with the bookable slot labels for that day.
@freezed
abstract class AvailabilityDay with _$AvailabilityDay {
  const factory AvailabilityDay({
    /// Calendar day (date only).
    required DateTime date,

    /// Bookable start times, 24-hour clock, e.g. `09:00`, `09:30`.
    @Default(<String>[]) List<String> slots,
  }) = _AvailabilityDay;
}
