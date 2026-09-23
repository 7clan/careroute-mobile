/// Form validation rules shared by the auth screens.
///
/// Pure functions → easy to unit test; the widgets simply surface the
/// returned messages as inline field errors (announced by semantics).
class Validators {
  static final RegExp _email = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  /// Returns an error message, or `null` when valid.
  static String? name(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter your full name.';
    if (v.length < 2) return 'Name looks too short.';
    if (v.length > 60) return 'Name looks too long.';
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter your email address.';
    if (!_email.hasMatch(v)) return 'Enter a valid email, e.g. name@mail.com.';
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Please choose a password.';
    if (v.length < 8) return 'Use at least 8 characters.';
    if (!v.contains(RegExp(r'[A-Za-z]'))) return 'Include at least one letter.';
    if (!v.contains(RegExp(r'[0-9]'))) return 'Include at least one number.';
    return null;
  }

  static String? passwordConfirmation(String? value, String original) {
    final v = value ?? '';
    if (v.isEmpty) return 'Please repeat your password.';
    if (v != original) return 'Passwords do not match.';
    return null;
  }

  /// For the appointment request reason — optional, but bounded.
  static String? reason(String? value) {
    final v = value?.trim() ?? '';
    if (v.length > 400) return 'Keep the reason under 400 characters.';
    return null;
  }
}
