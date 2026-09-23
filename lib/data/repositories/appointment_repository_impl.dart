import 'package:dio/dio.dart';

import '../../core/errors/app_exception.dart';
import '../../core/network/dio_exception_mapper.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../dto/appointment_dto.dart';
import '../mappers/appointment_mapper.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  AppointmentRepositoryImpl({required this.dio});

  final Dio dio;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AppException {
      rethrow;
    } catch (error, stackTrace) {
      throw DioExceptionMapper.map(error, stackTrace: stackTrace);
    }
  }

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  @override
  Future<List<Appointment>> fetchAppointments() {
    return _guard(() async {
      final response = await dio.get<Map<String, dynamic>>('/appointments');
      final items = response.data!['items'] as List<dynamic>;
      return [
        for (final item in items)
          AppointmentDto.fromJson(item as Map<String, dynamic>).toDomain(),
      ];
    });
  }

  @override
  Future<Appointment> requestAppointment({
    required String doctorId,
    required DateTime date,
    required String time,
    String? reason,
  }) {
    return _guard(() async {
      final response = await dio.post<Map<String, dynamic>>(
        '/appointments',
        data: {
          'doctorId': doctorId,
          'date': _dateKey(date),
          'time': time,
          'reason': reason,
        },
      );
      return AppointmentDto.fromJson(response.data!).toDomain();
    });
  }

  @override
  Future<Appointment> cancelAppointment(String id) {
    return _guard(() async {
      final response = await dio.post<Map<String, dynamic>>(
        '/appointments/$id/cancel',
      );
      return AppointmentDto.fromJson(response.data!).toDomain();
    });
  }
}
