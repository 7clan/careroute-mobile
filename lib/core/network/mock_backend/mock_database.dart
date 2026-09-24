import 'mock_http_error.dart';

/// Deterministic, in-process "CareRoute API".
///
/// This class is the local equivalent of a Laravel backend: it owns seeded
/// users, providers, and appointments, and answers a fixed set of REST
/// routes with realistic payloads and status codes. It is pure Dart — no
/// Dio, no Flutter — so repository tests can exercise it directly.
///
/// The network transport (status codes, headers, JSON bodies, latency,
/// failures) is applied by [MockBackendAdapter] in the same package.
class MockDatabase {
  MockDatabase._();

  /// Demo credentials documented in the README for quick review.
  static const demoEmail = 'demo@careroute.app';
  static const demoPassword = 'Demo1234!';

  factory MockDatabase.seeded() {
    final db = MockDatabase._();
    db._seed();
    return db;
  }

  // ---------------------------------------------------------------------------
  // Storage
  // ---------------------------------------------------------------------------

  final Map<String, _UserRow> _usersById = {};
  final Map<String, _UserRow> _usersByEmail = {};
  final Map<String, _TokenRow> _tokens = {}; // token -> token row
  final List<_DoctorRow> _doctors = [];
  final List<String> _specialtyIds = [];
  final Map<String, String> _specialtyNames = {};
  final Map<String, _AppointmentRow> _appointments = {};
  int _nextUserId = 1;
  int _nextAppointmentId = 1;

  static const _tokenLifetime = Duration(hours: 12);

  // ---------------------------------------------------------------------------
  // Seed data
  // ---------------------------------------------------------------------------

  static const List<String> _firstNames = [
    'Layal',
    'Rami',
    'Nadia',
    'Karim',
    'Maya',
    'Fadi',
    'Sara',
    'Elie',
    'Hala',
    'Ziad',
    'Rania',
    'Sami',
    'Nour',
    'Georges',
    'Joumana',
    'Walid',
    'Lea',
    'Marwan',
    'Dana',
    'Joe',
  ];

  static const List<String> _lastNames = [
    'Haddad',
    'Khoury',
    'Sfeir',
    'Nassar',
    'Chalhoub',
    'Awwad',
    'Barakat',
    'Hamdan',
    'Rahme',
    'Tannous',
    'Abou Jaoude',
    'Maalouf',
    'Saliba',
    'Habre',
    'Fares',
    'Kassab',
    'Attieh',
    'Boustany',
    'Doueiri',
    'Zoghbi',
  ];

  static const List<(String, String)> _specialties = [
    ('family-medicine', 'Family Medicine'),
    ('cardiology', 'Cardiology'),
    ('pediatrics', 'Pediatrics'),
    ('dermatology', 'Dermatology'),
    ('orthopedics', 'Orthopedics'),
    ('neurology', 'Neurology'),
    ('obgyn', 'Obstetrics & Gynecology'),
    ('ophthalmology', 'Ophthalmology'),
    ('ent', 'Ear, Nose & Throat'),
    ('psychiatry', 'Psychiatry'),
    ('dentistry', 'Dentistry'),
    ('endocrinology', 'Endocrinology'),
  ];

  static const List<String> _cities = [
    'Beirut',
    'Achrafieh',
    'Hamra',
    'Verdun',
    'Hazmieh',
    'Baabda',
    'Jbeil',
    'Batroun',
    'Tripoli',
    'Zahle',
    'Saida',
  ];

  static const List<String> _bios = [
    'Focused on clear communication and shared decision-making. Believes '
        'follow-up questions are part of good care.',
    'Takes time to explain test results in plain language and builds '
        'long-term relationships with patients.',
    'Evidence-first practice with an emphasis on prevention and practical '
        'lifestyle guidance.',
    'Known for a calm, unhurried consultation style and thorough '
        'explanations of treatment options.',
    'Combines up-to-date clinical guidelines with genuine listening — '
        'your concerns shape the plan.',
    'Patients describe the clinic as organized and reassuring, with '
        'clear next steps after every visit.',
  ];

  void _seed() {
    for (final (id, name) in _specialties) {
      _specialtyIds.add(id);
      _specialtyNames[id] = name;
    }
    var doctorSeq = 0;
    for (var s = 0; s < _specialtyIds.length; s++) {
      for (var i = 0; i < 6; i++) {
        doctorSeq++;
        final first = _firstNames[(s * 6 + i) % _firstNames.length];
        final last = _lastNames[(s * 6 + i * 3) % _lastNames.length];
        final city = _cities[(s * 5 + i * 2) % _cities.length];
        _doctors.add(
          _DoctorRow(
            id: 'd$doctorSeq',
            name: '$first $last',
            specialtyId: _specialtyIds[s],
            specialtyName: _specialtyNames[_specialtyIds[s]]!,
            city: city,
            address: '${_streets[(s + i) % _streets.length]}, $city',
            rating: 4.0 + ((i * 7 + s * 3) % 10) / 10,
            reviewCount: 18 + (i * 13 + s * 29) % 412,
            experienceYears: 3 + (i * 5 + s * 2) % 27,
            consultationFee: 30.0 + (((i * 11 + s * 7) % 20) * 5),
            languages: [
              'Arabic',
              'English',
              if (i % 3 == 0) 'French',
              if (i % 7 == 0) 'Armenian',
            ],
            education: _educationFor(s, i),
            bio: _bios[(s + i) % _bios.length],
            photoUrl:
                'https://i.pravatar.cc/300?img=${(doctorSeq * 3) % 70 + 1}',
            nextAvailableAt: _nextAvailable(i, s),
            isAcceptingNewPatients: i % 4 != 0,
            workDays: _workDaysFor(i),
            sessionHours: (i % 2 == 0)
                ? ('09:00', '13:00')
                : ('15:00', '19:00'),
          ),
        );
      }
    }
    _registerUser(
      id: 'u0',
      name: 'Demo Patient',
      email: demoEmail,
      password: demoPassword,
      memberSince: DateTime(2026, 1, 14),
    );
  }

  static const List<String> _streets = [
    'Rue Spears',
    'Bliss Street',
    'Monot Street',
    'Charles Malek Avenue',
    'Mar Elias Street',
    'Dora Highway',
    'Bechara El Khoury Street',
    'Clemenceau Street',
    'Nahr El Mot Road',
    'Main Street',
    'Sea Side Road',
  ];

  List<String> _educationFor(int s, int i) => [
    'MD — Université Saint-Joseph, Beirut',
    if (i % 2 == 0)
      'Residency — American University of Beirut Medical Center'
    else
      'Residency — Hôpital Hôtel-Dieu de France',
    if (i % 5 == 0) 'Fellowship — Hôpitaux Universitaires de Genève',
  ];

  static const List<String> _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  List<String> _workDaysFor(int i) => switch (i % 3) {
    0 => ['Monday', 'Tuesday', 'Thursday'],
    1 => ['Monday', 'Wednesday', 'Friday', 'Saturday'],
    _ => ['Tuesday', 'Wednesday', 'Thursday', 'Friday'],
  };

  DateTime _nextAvailable(int i, int s) {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day + 1 + (i + s) % 5,
      i % 2 == 0 ? 9 : 15,
    );
  }

  // ---------------------------------------------------------------------------
  // Router
  // ---------------------------------------------------------------------------

  /// Handles one API call. Returns the JSON body; throws [MockHttpError]
  /// for non-2xx responses.
  Map<String, Object?> handle({
    required String method,
    required String path,
    Map<String, String> query = const {},
    Map<String, dynamic>? body,
    String? token,
  }) {
    final segments = path
        .split('/')
        .where((segment) => segment.isNotEmpty)
        .toList();
    // Accept both '/v1/...' and '...' styles.
    if (segments.first == 'v1') {
      segments.removeAt(0);
    }
    final route = '/${segments.join('/')}';

    return switch ((method.toUpperCase(), route)) {
      ('POST', '/auth/register') => _register(body ?? const {}),
      ('POST', '/auth/login') => _login(body ?? const {}),
      ('POST', '/auth/logout') => _logout(token),
      ('GET', '/auth/me') => _me(token),
      ('GET', '/specialties') => {'items': _specialtiesJson()},
      ('GET', '/meta/cities') => {'items': _cities},
      ('GET', '/doctors') => _doctorsPage(query),
      ('GET', '/appointments') => _listAppointments(_requireUser(token)),
      ('POST', '/appointments') => _createAppointment(
        _requireUser(token),
        body ?? const {},
      ),
      _ when segments.length == 2 && segments[0] == 'doctors' => _doctorDetail(
        segments[1],
      ),
      _
          when segments.length == 3 &&
              segments[0] == 'doctors' &&
              segments[2] == 'availability' =>
        _availability(segments[1], query),
      _
          when segments.length == 3 &&
              segments[0] == 'appointments' &&
              segments[2] == 'cancel' &&
              method.toUpperCase() == 'POST' =>
        _cancelAppointment(_requireUser(token), segments[1]),
      _ => throw MockHttpError(404, {
        'message': 'No route matched $method $route',
      }),
    };
  }

  // ---------------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------------

  _UserRow _requireUser(String? token) {
    final user = _userForToken(token);
    if (user == null) {
      throw const MockHttpError(401, {
        'code': 'unauthorized',
        'message': 'Authentication required.',
      });
    }
    return user;
  }

  _UserRow? _userForToken(String? token) {
    if (token == null) return null;
    final row = _tokens[token];
    if (row == null) {
      // Tokens are self-describing (`mt_<userId>_<expiryMs>`), like a
      // signed JWT: an expired token is rejected even if it was pruned
      // from the active session store.
      final embedded = _parseTokenExpiry(token);
      if (embedded != null && DateTime.now().isAfter(embedded)) {
        throw const MockHttpError(401, {
          'code': 'token_expired',
          'message': 'The session has expired.',
        });
      }
      return null;
    }
    if (row.isExpired) {
      // Expired tokens are pruned lazily, like a real session store.
      _tokens.remove(token);
      throw const MockHttpError(401, {
        'code': 'token_expired',
        'message': 'The session has expired.',
      });
    }
    return _usersById[row.userId];
  }

  DateTime? _parseTokenExpiry(String token) {
    final parts = token.split('_');
    if (parts.length != 3 || parts[0] != 'mt') return null;
    final milliseconds = int.tryParse(parts[2]);
    return milliseconds == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  Map<String, Object?> _register(Map<String, dynamic> body) {
    final errors = <String, List<String>>{};
    final name = (body['name'] as String? ?? '').trim();
    final email = (body['email'] as String? ?? '').trim().toLowerCase();
    final password = body['password'] as String? ?? '';
    final confirmation = body['passwordConfirmation'] as String? ?? '';

    if (name.length < 2) {
      errors['name'] = ['Name must be at least 2 characters.'];
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      errors['email'] = ['Enter a valid email address.'];
    } else if (_usersByEmail.containsKey(email)) {
      errors['email'] = ['This email is already registered.'];
    }
    if (password.length < 8) {
      errors['password'] = ['Password must be at least 8 characters.'];
    } else if (!password.contains(RegExp(r'[A-Za-z]')) ||
        !password.contains(RegExp(r'[0-9]'))) {
      errors['password'] = ['Password must contain letters and numbers.'];
    }
    if (confirmation != password) {
      errors['passwordConfirmation'] = ['Passwords do not match.'];
    }
    if (errors.isNotEmpty) {
      throw MockHttpError(422, {
        'message': 'Validation failed.',
        'errors': errors,
      });
    }

    final user = _registerUser(
      id: 'u$_nextUserId',
      name: name,
      email: email,
      password: password,
      memberSince: DateTime.now(),
    );
    return _authResponse(user);
  }

  Map<String, Object?> _login(Map<String, dynamic> body) {
    final email = (body['email'] as String? ?? '').trim().toLowerCase();
    final password = body['password'] as String? ?? '';
    final user = _usersByEmail[email];
    if (user == null || user.password != password) {
      throw const MockHttpError(401, {
        'code': 'invalid_credentials',
        'message': 'These credentials do not match our records.',
      });
    }
    return _authResponse(user);
  }

  Map<String, Object?> _logout(String? token) {
    if (token != null) _tokens.remove(token);
    return {'message': 'Signed out.'};
  }

  Map<String, Object?> _me(String? token) {
    final user = _requireUser(token);
    return {'user': user.toJson()};
  }

  _UserRow _registerUser({
    required String id,
    required String name,
    required String email,
    required String password,
    required DateTime memberSince,
  }) {
    _nextUserId++;
    final user = _UserRow(
      id: id,
      name: name,
      email: email,
      password: password,
      memberSince: memberSince,
    );
    _usersById[id] = user;
    _usersByEmail[email] = user;
    return user;
  }

  Map<String, Object?> _authResponse(_UserRow user) {
    final expiresAt = DateTime.now().add(_tokenLifetime);
    final token = 'mt_${user.id}_${expiresAt.millisecondsSinceEpoch}';
    _tokens[token] = _TokenRow(userId: user.id, expiresAt: expiresAt);
    return {
      'token': token,
      'tokenType': 'Bearer',
      'expiresAt': expiresAt.toIso8601String(),
      'user': user.toJson(),
    };
  }

  // ---------------------------------------------------------------------------
  // Discovery
  // ---------------------------------------------------------------------------

  Map<String, Object?> _doctorsPage(Map<String, String> query) {
    final ids = query['ids'];
    if (ids != null && ids.isNotEmpty) {
      final wanted = ids.split(',');
      final found = _doctors
          .where((d) => wanted.contains(d.id))
          .map((d) => d.toJson(includeSessions: false))
          .toList();
      return {
        'items': found,
        'page': 1,
        'pageSize': found.length,
        'totalCount': found.length,
        'totalPages': 1,
      };
    }

    var doctors = List<_DoctorRow>.from(_doctors);

    final search = (query['search'] ?? '').trim().toLowerCase();
    if (search.isNotEmpty) {
      doctors = doctors
          .where(
            (d) =>
                d.name.toLowerCase().contains(search) ||
                d.specialtyName.toLowerCase().contains(search) ||
                d.city.toLowerCase().contains(search),
          )
          .toList();
    }
    final specialtyId = query['specialtyId'];
    if (specialtyId != null && specialtyId.isNotEmpty) {
      doctors = doctors.where((d) => d.specialtyId == specialtyId).toList();
    }
    final city = query['city'];
    if (city != null && city.isNotEmpty) {
      doctors = doctors.where((d) => d.city == city).toList();
    }

    doctors = switch (query['sort'] ?? 'rating') {
      'fee' => [
        ...doctors,
      ]..sort((a, b) => a.consultationFee.compareTo(b.consultationFee)),
      'experience' => [
        ...doctors,
      ]..sort((a, b) => b.experienceYears.compareTo(a.experienceYears)),
      _ => [...doctors]..sort((a, b) => b.rating.compareTo(a.rating)),
    };

    final page = _intParam(query, 'page', 1);
    final pageSize = _intParam(query, 'pageSize', 10).clamp(1, 50);
    if (page < 1) {
      throw const MockHttpError(422, {
        'message': 'Validation failed.',
        'errors': {
          'page': ['Page must be 1 or greater.'],
        },
      });
    }
    final total = doctors.length;
    final totalPages = (total / pageSize).ceil();
    final start = (page - 1) * pageSize;
    final items = (start >= total)
        ? <_DoctorRow>[]
        : doctors.skip(start).take(pageSize).toList();

    return {
      'items': items.map((d) => d.toJson(includeSessions: false)).toList(),
      'page': page,
      'pageSize': pageSize,
      'totalCount': total,
      'totalPages': totalPages,
    };
  }

  _DoctorRow? _byId(String id) {
    for (final doctor in _doctors) {
      if (doctor.id == id) return doctor;
    }
    return null;
  }

  Map<String, Object?> _doctorDetail(String id) {
    final doctor = _byId(id);
    if (doctor == null) {
      throw MockHttpError(404, {
        'code': 'provider_not_found',
        'message': 'Provider $id was not found.',
      });
    }
    return doctor.toJson(includeSessions: true);
  }

  Map<String, Object?> _availability(
    String doctorId,
    Map<String, String> query,
  ) {
    final doctor = _byId(doctorId);
    if (doctor == null) {
      throw MockHttpError(404, {
        'code': 'provider_not_found',
        'message': 'Provider $doctorId was not found.',
      });
    }
    final days = _intParam(query, 'days', 14).clamp(1, 30);
    final today = DateTime.now();
    final dayList = <Map<String, Object?>>[];
    for (var offset = 1; offset <= days; offset++) {
      final date = DateTime(today.year, today.month, today.day + offset);
      if (doctor.workDays.contains(_weekdays[date.weekday - 1])) {
        dayList.add({
          'date': _dateKey(date),
          'slots': _slotsBetween(
            doctor.sessionHours.$1,
            doctor.sessionHours.$2,
          ),
        });
      }
    }
    return {'doctorId': doctorId, 'days': dayList};
  }

  List<Map<String, Object?>> _specialtiesJson() => [
    for (final id in _specialtyIds)
      {
        'id': id,
        'name': _specialtyNames[id],
        'doctorCount': _doctors.where((d) => d.specialtyId == id).length,
      },
  ];

  // ---------------------------------------------------------------------------
  // Appointments
  // ---------------------------------------------------------------------------

  Map<String, Object?> _listAppointments(_UserRow user) {
    final items =
        _appointments.values
            .where((a) => a.userId == user.id)
            .map((a) => a.toJson())
            .toList()
          ..sort(
            (a, b) =>
                (b['createdAt'] as String).compareTo(a['createdAt'] as String),
          );
    return {'items': items};
  }

  Map<String, Object?> _createAppointment(
    _UserRow user,
    Map<String, dynamic> body,
  ) {
    final errors = <String, List<String>>{};
    final doctorId = body['doctorId'] as String? ?? '';
    final date = body['date'] as String? ?? '';
    final time = body['time'] as String? ?? '';
    final reason = ((body['reason'] as String?) ?? '').trim();

    _DoctorRow? doctor;
    if (doctorId.isEmpty) {
      errors['doctorId'] = ['Choose a provider.'];
    } else {
      doctor = _byId(doctorId);
      if (doctor == null) {
        throw MockHttpError(404, {
          'code': 'provider_not_found',
          'message': 'Provider $doctorId was not found.',
        });
      }
    }

    DateTime? parsedDate;
    if (date.isEmpty) {
      errors['date'] = ['Choose a date.'];
    } else {
      parsedDate = DateTime.tryParse(date);
      if (parsedDate == null) {
        errors['date'] = ['Date must use the YYYY-MM-DD format.'];
      }
    }
    if (time.isEmpty) {
      errors['time'] = ['Choose a time.'];
    }
    if (reason.length > 400) {
      errors['reason'] = ['Keep the reason under 400 characters.'];
    }

    if (parsedDate != null && doctor != null) {
      final today = DateTime.now();
      final todayKey = _dateKey(DateTime(today.year, today.month, today.day));
      if (_dateKey(parsedDate).compareTo(todayKey) <= 0) {
        errors['date'] = ['Pick a future date.'];
      } else if (!_isSlotValid(doctor, parsedDate, time)) {
        errors['time'] = ['This slot is not offered by the provider.'];
      } else {
        final clash = _appointments.values.any(
          (a) =>
              a.userId == user.id &&
              a.doctorId == doctor!.id &&
              a.date == _dateKey(parsedDate!) &&
              a.time == time &&
              a.status != 'cancelled',
        );
        if (clash) {
          errors['time'] = ['You already requested this slot.'];
        }
      }
    }

    if (errors.isNotEmpty) {
      throw MockHttpError(422, {
        'message': 'Validation failed.',
        'errors': errors,
      });
    }

    final appointment = _AppointmentRow(
      id: 'a$_nextAppointmentId',
      userId: user.id,
      doctorId: doctor!.id,
      doctorName: doctor.name,
      specialtyName: doctor.specialtyName,
      date: _dateKey(parsedDate!),
      time: time,
      reason: reason.isEmpty ? null : reason,
      status: 'pending',
      createdAt: DateTime.now(),
    );
    _nextAppointmentId++;
    _appointments[appointment.id] = appointment;
    return appointment.toJson();
  }

  Map<String, Object?> _cancelAppointment(_UserRow user, String id) {
    final row = _appointments[id];
    if (row == null || row.userId != user.id) {
      throw MockHttpError(404, {
        'code': 'appointment_not_found',
        'message': 'Appointment $id was not found.',
      });
    }
    final updated = _AppointmentRow(
      id: row.id,
      userId: row.userId,
      doctorId: row.doctorId,
      doctorName: row.doctorName,
      specialtyName: row.specialtyName,
      date: row.date,
      time: row.time,
      reason: row.reason,
      status: 'cancelled',
      createdAt: row.createdAt,
    );
    _appointments[id] = updated;
    return updated.toJson();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  bool _isSlotValid(_DoctorRow doctor, DateTime date, String time) {
    if (!doctor.workDays.contains(_weekdays[date.weekday - 1])) return false;
    return _slotsBetween(
      doctor.sessionHours.$1,
      doctor.sessionHours.$2,
    ).contains(time);
  }

  static List<String> _slotsBetween(String from, String to) {
    final start = _minutesOf(from);
    final end = _minutesOf(to);
    return [
      for (var m = start; m < end; m += 30)
        '${(m ~/ 60).toString().padLeft(2, '0')}:'
            '${(m % 60).toString().padLeft(2, '0')}',
    ];
  }

  static int _minutesOf(String hhmm) {
    final parts = hhmm.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  int _intParam(Map<String, String> query, String key, int fallback) {
    final raw = query[key];
    if (raw == null || raw.isEmpty) return fallback;
    return int.tryParse(raw) ?? fallback;
  }
}

// -----------------------------------------------------------------------------
// Rows
// -----------------------------------------------------------------------------

class _UserRow {
  _UserRow({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.memberSince,
  });

  final String id;
  final String name;
  final String email;
  // Plain-text on purpose: this is a mock session store, not real security.
  final String password;
  final DateTime memberSince;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'memberSince': memberSince.toIso8601String(),
  };
}

class _TokenRow {
  _TokenRow({required this.userId, required this.expiresAt});

  final String userId;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class _DoctorRow {
  _DoctorRow({
    required this.id,
    required this.name,
    required this.specialtyId,
    required this.specialtyName,
    required this.city,
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.experienceYears,
    required this.consultationFee,
    required this.languages,
    required this.education,
    required this.bio,
    required this.photoUrl,
    required this.nextAvailableAt,
    required this.isAcceptingNewPatients,
    required this.workDays,
    required this.sessionHours,
  });

  final String id;
  final String name;
  final String specialtyId;
  final String specialtyName;
  final String city;
  final String address;
  final double rating;
  final int reviewCount;
  final int experienceYears;
  final double consultationFee;
  final List<String> languages;
  final List<String> education;
  final String bio;
  final String photoUrl;
  final DateTime nextAvailableAt;
  final bool isAcceptingNewPatients;
  final List<String> workDays;
  final (String, String) sessionHours;

  Map<String, Object?> toJson({required bool includeSessions}) => {
    'id': id,
    'name': name,
    'specialtyId': specialtyId,
    'specialtyName': specialtyName,
    'city': city,
    'address': address,
    'rating': rating,
    'reviewCount': reviewCount,
    'experienceYears': experienceYears,
    'consultationFee': consultationFee,
    'languages': languages,
    'education': education,
    'bio': bio,
    'photoUrl': photoUrl,
    'nextAvailableAt': nextAvailableAt.toIso8601String(),
    'isAcceptingNewPatients': isAcceptingNewPatients,
    if (includeSessions)
      'sessions': [
        for (final day in workDays)
          {'day': day, 'from': sessionHours.$1, 'to': sessionHours.$2},
      ],
  };
}

class _AppointmentRow {
  _AppointmentRow({
    required this.id,
    required this.userId,
    required this.doctorId,
    required this.doctorName,
    required this.specialtyName,
    required this.date,
    required this.time,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String doctorId;
  final String doctorName;
  final String specialtyName;
  final String date;
  final String time;
  final String? reason;
  final String status;
  final DateTime createdAt;

  Map<String, Object?> toJson() => {
    'id': id,
    'doctorId': doctorId,
    'doctorName': doctorName,
    'specialtyName': specialtyName,
    'date': date,
    'time': time,
    'reason': reason,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };
}
