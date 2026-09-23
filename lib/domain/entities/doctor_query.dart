import 'package:freezed_annotation/freezed_annotation.dart';

part 'doctor_query.freezed.dart';

/// Search & filter criteria for the provider discovery feed.
///
/// The UI mutates this through [DoctorFiltersController]; repositories
/// translate it into API request parameters.
@freezed
abstract class DoctorQuery with _$DoctorQuery {
  const factory DoctorQuery({
    /// Free-text search over provider name / specialty / city.
    @Default('') String search,

    /// Specialty id filter, or `null` for "all specialties".
    String? specialtyId,

    /// City filter, or `null` for "all cities".
    String? city,

    /// 1-based page index.
    @Default(1) int page,
    @Default(10) int pageSize,
  }) = _DoctorQuery;

  const DoctorQuery._();

  /// A query pointing at the first page with the same filters — used when a
  /// filter changes and the feed must restart from the top.
  DoctorQuery get firstPage => copyWith(page: 1);
}
