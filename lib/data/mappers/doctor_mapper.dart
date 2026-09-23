import '../../domain/entities/availability.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/entities/doctor_page.dart';
import '../../domain/entities/specialty.dart';
import '../dto/availability_dto.dart';
import '../dto/doctor_dto.dart';
import '../dto/doctor_page_dto.dart';
import '../dto/specialty_dto.dart';

/// DTO → domain mapping keeps wire formats out of the presentation and
/// domain layers. If the API adds or renames a field, only this file (and
/// the DTOs) change.
extension DoctorDtoMapper on DoctorDto {
  Doctor toDomain() => Doctor(
    id: id,
    name: name,
    specialtyId: specialtyId,
    specialtyName: specialtyName,
    city: city,
    address: address,
    rating: rating,
    reviewCount: reviewCount,
    experienceYears: experienceYears,
    consultationFee: consultationFee,
    languages: List.unmodifiable(languages),
    education: List.unmodifiable(education),
    bio: bio,
    photoUrl: photoUrl,
    nextAvailableAt: nextAvailableAt,
    isAcceptingNewPatients: isAcceptingNewPatients,
    sessions: List.unmodifiable(
      (sessions ?? const []).map(
        (s) => WeeklySession(day: s.day, from: s.from, to: s.to),
      ),
    ),
  );
}

extension DoctorPageDtoMapper on DoctorPageDto {
  DoctorPage toDomain() => DoctorPage(
    items: List.unmodifiable(items.map((d) => d.toDomain())),
    page: page,
    pageSize: pageSize,
    totalCount: totalCount,
    totalPages: totalPages,
  );
}

extension SpecialtyDtoMapper on SpecialtyDto {
  Specialty toDomain() =>
      Specialty(id: id, name: name, doctorCount: doctorCount);
}

extension AvailabilityDayDtoMapper on AvailabilityDayDto {
  AvailabilityDay toDomain() => AvailabilityDay(
    date: DateTime.parse(date),
    slots: List.unmodifiable(slots),
  );
}
