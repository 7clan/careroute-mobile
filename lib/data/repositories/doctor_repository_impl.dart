import 'package:dio/dio.dart';

import '../../core/errors/app_exception.dart';
import '../../core/network/dio_exception_mapper.dart';
import '../../domain/entities/availability.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/entities/doctor_page.dart';
import '../../domain/entities/doctor_query.dart';
import '../../domain/entities/specialty.dart';
import '../../domain/repositories/doctor_repository.dart';
import '../dto/availability_dto.dart';
import '../dto/doctor_dto.dart';
import '../dto/doctor_page_dto.dart';
import '../dto/specialty_dto.dart';
import '../mappers/doctor_mapper.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  DoctorRepositoryImpl({required this.dio});

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

  @override
  Future<DoctorPage> fetchDoctors(DoctorQuery query) {
    return _guard(() async {
      final response = await dio.get<Map<String, dynamic>>(
        '/doctors',
        queryParameters: {
          'page': query.page,
          'pageSize': query.pageSize,
          if (query.search.isNotEmpty) 'search': query.search,
          if (query.specialtyId != null) 'specialtyId': query.specialtyId,
          if (query.city != null) 'city': query.city,
        },
      );
      return DoctorPageDto.fromJson(response.data!).toDomain();
    });
  }

  @override
  Future<Doctor> fetchDoctorDetail(String id) {
    return _guard(() async {
      final response = await dio.get<Map<String, dynamic>>('/doctors/$id');
      return DoctorDto.fromJson(response.data!).toDomain();
    });
  }

  @override
  Future<List<Specialty>> fetchSpecialties() {
    return _guard(() async {
      final response = await dio.get<Map<String, dynamic>>('/specialties');
      final items = response.data!['items'] as List<dynamic>;
      return [
        for (final item in items)
          SpecialtyDto.fromJson(item as Map<String, dynamic>).toDomain(),
      ];
    });
  }

  @override
  Future<List<String>> fetchCities() {
    return _guard(() async {
      final response = await dio.get<Map<String, dynamic>>('/meta/cities');
      final items = response.data!['items'] as List<dynamic>;
      return [for (final item in items) item.toString()];
    });
  }

  @override
  Future<List<AvailabilityDay>> fetchAvailability(
    String doctorId, {
    int days = 14,
  }) {
    return _guard(() async {
      final response = await dio.get<Map<String, dynamic>>(
        '/doctors/$doctorId/availability',
        queryParameters: {'days': days},
      );
      final dto = AvailabilityResponseDto.fromJson(response.data!);
      return [for (final day in dto.days) day.toDomain()];
    });
  }

  @override
  Future<List<Doctor>> fetchDoctorsByIds(List<String> ids) {
    return _guard(() async {
      if (ids.isEmpty) return const <Doctor>[];
      final response = await dio.get<Map<String, dynamic>>(
        '/doctors',
        queryParameters: {'ids': ids.join(',')},
      );
      final page = DoctorPageDto.fromJson(response.data!).toDomain();
      return page.items;
    });
  }
}
