import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';

/// The signed-in CareRoute user (domain representation).
@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String name,
    required String email,

    /// Optional profile phone number.
    String? phone,
    required DateTime memberSince,
  }) = _AppUser;
}
