import 'package:freezed_annotation/freezed_annotation.dart';

part 'specialty.freezed.dart';

/// A medical specialty used to group and filter providers.
@freezed
abstract class Specialty with _$Specialty {
  const factory Specialty({
    required String id,
    required String name,

    /// Number of providers currently listed under this specialty.
    required int doctorCount,
  }) = _Specialty;
}
