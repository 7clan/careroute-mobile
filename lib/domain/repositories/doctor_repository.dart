import '../entities/availability.dart';
import '../entities/doctor.dart';
import '../entities/doctor_page.dart';
import '../entities/doctor_query.dart';
import '../entities/specialty.dart';

/// Provider discovery contract used by the presentation layer.
abstract interface class DoctorRepository {
  /// Fetches a single page of providers matching [query].
  Future<DoctorPage> fetchDoctors(DoctorQuery query);

  /// Fetches the full profile of a single provider.
  ///
  /// Throws [NotFoundException] when no provider matches [id].
  Future<Doctor> fetchDoctorDetail(String id);

  /// Fetches all medical specialties with provider counts.
  Future<List<Specialty>> fetchSpecialties();

  /// Fetches the distinct cities providers operate in (filter options).
  Future<List<String>> fetchCities();

  /// Fetches the bookable calendar for a provider starting tomorrow,
  /// covering [days] days.
  Future<List<AvailabilityDay>> fetchAvailability(String doctorId, {int days});

  /// Fetches providers by exact ids (used by the favorites screen).
  Future<List<Doctor>> fetchDoctorsByIds(List<String> ids);
}
