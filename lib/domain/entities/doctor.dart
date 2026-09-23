import 'package:freezed_annotation/freezed_annotation.dart';

part 'doctor.freezed.dart';

/// One recurring weekly session block, e.g. Mondays 09:00–13:00.
@freezed
abstract class WeeklySession with _$WeeklySession {
  const factory WeeklySession({
    required String day,
    required String from,
    required String to,
  }) = _WeeklySession;
}

/// A healthcare provider discoverable through CareRoute.
///
/// Domain entity — UI and repositories communicate using this type.
/// JSON parsing lives in the data layer (`DoctorDto`), keeping this class
/// free of serialization concerns.
@freezed
abstract class Doctor with _$Doctor {
  const factory Doctor({
    required String id,
    required String name,
    required String specialtyId,
    required String specialtyName,
    required String city,
    required String address,
    required double rating,
    required int reviewCount,
    required int experienceYears,
    required double consultationFee,
    @Default(<String>[]) List<String> languages,
    @Default(<String>[]) List<String> education,
    required String bio,
    required String photoUrl,

    /// Nearest future moment the provider can be seen, if known.
    DateTime? nextAvailableAt,

    /// Populated only by [DoctorRepository.fetchDoctorDetail];
    /// list responses leave this empty to keep payloads light.
    @Default(false) bool isAcceptingNewPatients,

    /// Recurring weekly session blocks (detail responses only).
    @Default(<WeeklySession>[]) List<WeeklySession> sessions,
  }) = _Doctor;
}
