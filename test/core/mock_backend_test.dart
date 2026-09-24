import 'package:flutter_test/flutter_test.dart';

import 'package:careroute_mobile/core/network/mock_backend/mock_database.dart';
import 'package:careroute_mobile/core/network/mock_backend/mock_http_error.dart';

void main() {
  late MockDatabase db;

  setUp(() {
    db = MockDatabase.seeded();
  });

  Map<String, Object?> call({
    required String method,
    required String path,
    Map<String, String> query = const {},
    Map<String, dynamic>? body,
    String? token,
  }) {
    return db.handle(
      method: method,
      path: path,
      query: query,
      body: body,
      token: token,
    );
  }

  group('seeding', () {
    test('seeds 12 specialties with 6 providers each', () {
      final specialties = call(method: 'GET', path: '/specialties');
      final items = specialties['items'] as List;
      expect(items, hasLength(12));
      for (final item in items) {
        expect((item as Map)['doctorCount'], 6);
      }
    });

    test('exposes distinct cities', () {
      final cities = call(method: 'GET', path: '/meta/cities');
      final items = cities['items'] as List;
      expect(items.toSet().length, items.length);
      expect(items, contains('Beirut'));
    });
  });

  group('discovery', () {
    test('paginates deterministically', () {
      final page1 = call(method: 'GET', path: '/doctors');
      expect(page1['page'], 1);
      expect(page1['pageSize'], 10);
      expect(page1['totalCount'], 72);
      expect(page1['totalPages'], 8);
      expect((page1['items'] as List), hasLength(10));

      final page8 = call(method: 'GET', path: '/doctors', query: {'page': '8'});
      expect((page8['items'] as List), hasLength(2));
      final page9 = call(method: 'GET', path: '/doctors', query: {'page': '9'});
      expect((page9['items'] as List), isEmpty);
    });

    test('search matches name, specialty and city case-insensitively', () {
      final bySpecialty = call(
        method: 'GET',
        path: '/doctors',
        query: {'search': 'CARDIOLOGY'},
      );
      expect(bySpecialty['totalCount'], 6);

      final byCity = call(
        method: 'GET',
        path: '/doctors',
        query: {'search': 'tripoli'},
      );
      expect(byCity['totalCount'], greaterThan(0));
      for (final item in byCity['items'] as List) {
        expect((item as Map)['city'], 'Tripoli');
      }
    });

    test('specialty and city filters compose with search', () {
      final result = call(
        method: 'GET',
        path: '/doctors',
        query: {'specialtyId': 'cardiology', 'city': 'Beirut'},
      );
      for (final item in result['items'] as List) {
        final doctor = item as Map;
        expect(doctor['specialtyId'], 'cardiology');
        expect(doctor['city'], 'Beirut');
      }
    });

    test('rejects non-positive pages with 422', () {
      expect(
        () => call(method: 'GET', path: '/doctors', query: {'page': '0'}),
        throwsA(
          isA<MockHttpError>().having(
            (error) => error.statusCode,
            'status',
            422,
          ),
        ),
      );
    });

    test('unknown provider id answers 404', () {
      expect(
        () => call(method: 'GET', path: '/doctors/nope'),
        throwsA(
          isA<MockHttpError>().having(
            (error) => error.statusCode,
            'status',
            404,
          ),
        ),
      );
    });

    test('detail includes weekly sessions; list does not', () {
      final list = call(method: 'GET', path: '/doctors');
      final listItem = (list['items'] as List).first as Map;
      expect(listItem.containsKey('sessions'), isFalse);

      final detail = call(method: 'GET', path: '/doctors/${listItem['id']}');
      expect(detail.containsKey('sessions'), isTrue);
      expect(detail['sessions'] as List, isNotEmpty);
    });

    test('availability covers only working days with 30-minute slots', () {
      final detail = call(method: 'GET', path: '/doctors/d1');
      final sessions = detail['sessions'] as List;
      final workDays = sessions.map((s) => (s as Map)['day']).toSet();

      final availability = call(
        method: 'GET',
        path: '/doctors/d1/availability',
        query: {'days': '21'},
      );
      for (final day in availability['days'] as List) {
        final dayMap = day as Map;
        final date = DateTime.parse(dayMap['date'] as String);
        final weekday = [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday',
        ][date.weekday - 1];
        expect(workDays, contains(weekday));
        for (final slot in dayMap['slots'] as List) {
          final minutes = int.parse(slot.toString().split(':')[1]);
          expect(minutes % 30, 0);
        }
      }
    });

    test('fetch by ids ignores other filters', () {
      final result = call(
        method: 'GET',
        path: '/doctors',
        query: {'ids': 'd1,d3,d5', 'search': 'zzz-no-match'},
      );
      expect((result['items'] as List), hasLength(3));
    });
  });

  group('auth', () {
    test('login rejects wrong credentials with 401', () {
      expect(
        () => call(
          method: 'POST',
          path: '/auth/login',
          body: {'email': 'demo@careroute.app', 'password': 'wrong'},
        ),
        throwsA(
          isA<MockHttpError>().having(
            (error) => error.statusCode,
            'status',
            401,
          ),
        ),
      );
    });

    test('login with the demo account returns a session', () {
      final response = call(
        method: 'POST',
        path: '/auth/login',
        body: {'email': 'demo@careroute.app', 'password': 'Demo1234!'},
      );
      expect(response['token'], isA<String>());
      expect((response['user'] as Map)['email'], 'demo@careroute.app');
    });

    test('register validates fields and reports 422 with errors', () {
      expect(
        () => call(
          method: 'POST',
          path: '/auth/register',
          body: {
            'name': 'A',
            'email': 'not-an-email',
            'password': 'short',
            'passwordConfirmation': 'different',
          },
        ),
        throwsA(
          isA<MockHttpError>()
              .having((error) => error.statusCode, 'status', 422)
              .having(
                (error) => (error.body['errors'] as Map).keys.toSet(),
                'field errors',
                containsAll([
                  'name',
                  'email',
                  'password',
                  'passwordConfirmation',
                ]),
              ),
        ),
      );
    });

    test('registering an existing email fails with 422', () {
      expect(
        () => call(
          method: 'POST',
          path: '/auth/register',
          body: {
            'name': 'Someone New',
            'email': 'demo@careroute.app',
            'password': 'Password1',
            'passwordConfirmation': 'Password1',
          },
        ),
        throwsA(
          isA<MockHttpError>()
              .having((error) => error.statusCode, 'status', 422)
              .having(
                (error) => (error.body['errors'] as Map)['email'],
                'email errors',
                isNotEmpty,
              ),
        ),
      );
    });

    test('protected endpoints reject anonymous access with 401', () {
      expect(
        () => call(method: 'GET', path: '/appointments'),
        throwsA(
          isA<MockHttpError>().having(
            (error) => error.statusCode,
            'status',
            401,
          ),
        ),
      );
    });

    test('tokens expire and then answer 401', () async {
      final login = call(
        method: 'POST',
        path: '/auth/login',
        body: {'email': 'demo@careroute.app', 'password': 'Demo1234!'},
      );
      final token = login['token'] as String;

      final me = call(method: 'GET', path: '/auth/me', token: token);
      expect((me['user'] as Map)['id'], 'u0');

      // Craft an expired token the same way the database issues them.
      final expired =
          'mt_u0_${DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch}';
      expect(
        () => call(method: 'GET', path: '/auth/me', token: expired),
        throwsA(
          isA<MockHttpError>()
              .having((error) => error.statusCode, 'status', 401)
              .having((error) => error.body['code'], 'code', 'token_expired'),
        ),
      );
    });

    test('logout invalidates the token', () {
      final login = call(
        method: 'POST',
        path: '/auth/login',
        body: {'email': 'demo@careroute.app', 'password': 'Demo1234!'},
      );
      final token = login['token'] as String;

      call(method: 'POST', path: '/auth/logout', token: token);

      expect(
        () => call(method: 'GET', path: '/auth/me', token: token),
        throwsA(
          isA<MockHttpError>().having(
            (error) => error.statusCode,
            'status',
            401,
          ),
        ),
      );
    });
  });

  group('appointments', () {
    String login() {
      return call(
            method: 'POST',
            path: '/auth/login',
            body: {'email': 'demo@careroute.app', 'password': 'Demo1234!'},
          )['token']
          as String;
    }

    (String, String, String) firstBookableSlot(String token) {
      final availability = call(
        method: 'GET',
        path: '/doctors/d1/availability',
        query: {'days': '21'},
        token: token,
      );
      final firstDay = (availability['days'] as List).first as Map;
      return (
        firstDay['date'] as String,
        (firstDay['slots'] as List).first as String,
        firstDay['date'] as String,
      );
    }

    test('requests an appointment and lists it', () {
      final token = login();
      final (date, slot, _) = firstBookableSlot(token);

      final created = call(
        method: 'POST',
        path: '/appointments',
        token: token,
        body: {
          'doctorId': 'd1',
          'date': date,
          'time': slot,
          'reason': 'Annual check-up',
        },
      );
      expect(created['status'], 'pending');
      expect(created['doctorId'], 'd1');

      final list = call(method: 'GET', path: '/appointments', token: token);
      expect((list['items'] as List), hasLength(1));
    });

    test('rejects a past date with 422', () {
      final token = login();
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final dateKey =
          '${yesterday.year.toString().padLeft(4, '0')}-'
          '${yesterday.month.toString().padLeft(2, '0')}-'
          '${yesterday.day.toString().padLeft(2, '0')}';

      expect(
        () => call(
          method: 'POST',
          path: '/appointments',
          token: token,
          body: {'doctorId': 'd1', 'date': dateKey, 'time': '09:00'},
        ),
        throwsA(
          isA<MockHttpError>()
              .having((error) => error.statusCode, 'status', 422)
              .having(
                (error) => (error.body['errors'] as Map)['date'],
                'date errors',
                isNotEmpty,
              ),
        ),
      );
    });

    test('rejects a slot the provider does not offer', () {
      final token = login();
      // Build a date that falls on a working day but pick an off-hours time.
      final availability = call(
        method: 'GET',
        path: '/doctors/d1/availability',
        query: {'days': '21'},
        token: token,
      );
      final date = ((availability['days'] as List).first as Map)['date'];

      expect(
        () => call(
          method: 'POST',
          path: '/appointments',
          token: token,
          body: {'doctorId': 'd1', 'date': date, 'time': '03:30'},
        ),
        throwsA(
          isA<MockHttpError>().having(
            (error) => (error.body['errors'] as Map)['time'],
            'time errors',
            isNotEmpty,
          ),
        ),
      );
    });

    test('rejects duplicate bookings of the same slot', () {
      final token = login();
      final (date, slot, _) = firstBookableSlot(token);
      final body = {'doctorId': 'd1', 'date': date, 'time': slot};

      call(method: 'POST', path: '/appointments', token: token, body: body);

      expect(
        () => call(
          method: 'POST',
          path: '/appointments',
          token: token,
          body: body,
        ),
        throwsA(
          isA<MockHttpError>().having(
            (error) => (error.body['errors'] as Map)['time'],
            'time errors',
            isNotEmpty,
          ),
        ),
      );
    });

    test('cancel marks the appointment as cancelled', () {
      final token = login();
      final (date, slot, _) = firstBookableSlot(token);
      final created = call(
        method: 'POST',
        path: '/appointments',
        token: token,
        body: {'doctorId': 'd1', 'date': date, 'time': slot},
      );

      final cancelled = call(
        method: 'POST',
        path: '/appointments/${created['id']}/cancel',
        token: token,
      );
      expect(cancelled['status'], 'cancelled');

      // A cancelled slot can be booked again.
      final rebooked = call(
        method: 'POST',
        path: '/appointments',
        token: token,
        body: {'doctorId': 'd1', 'date': date, 'time': slot},
      );
      expect(rebooked['status'], 'pending');
    });

    test('unknown route answers 404', () {
      expect(
        () => call(method: 'GET', path: '/nope'),
        throwsA(
          isA<MockHttpError>().having(
            (error) => error.statusCode,
            'status',
            404,
          ),
        ),
      );
    });
  });
}
