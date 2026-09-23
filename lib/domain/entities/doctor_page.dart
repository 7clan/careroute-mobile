import 'package:freezed_annotation/freezed_annotation.dart';

import 'doctor.dart';

part 'doctor_page.freezed.dart';

/// One page of provider results plus pagination metadata.
@freezed
abstract class DoctorPage with _$DoctorPage {
  const factory DoctorPage({
    required List<Doctor> items,
    required int page,
    required int pageSize,

    /// Total number of providers matching the query (all pages).
    required int totalCount,
    required int totalPages,
  }) = _DoctorPage;

  const DoctorPage._();

  bool get hasMore => page < totalPages;

  static const DoctorPage empty = DoctorPage(
    items: [],
    page: 1,
    pageSize: 10,
    totalCount: 0,
    totalPages: 0,
  );
}
