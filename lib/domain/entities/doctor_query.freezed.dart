// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'doctor_query.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DoctorQuery {

/// Free-text search over provider name / specialty / city.
 String get search;/// Specialty id filter, or `null` for "all specialties".
 String? get specialtyId;/// City filter, or `null` for "all cities".
 String? get city;/// 1-based page index.
 int get page; int get pageSize;
/// Create a copy of DoctorQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DoctorQueryCopyWith<DoctorQuery> get copyWith => _$DoctorQueryCopyWithImpl<DoctorQuery>(this as DoctorQuery, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DoctorQuery;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DoctorQuery&&(identical(other.search, _this.search) || other.search == _this.search)&&(identical(other.specialtyId, _this.specialtyId) || other.specialtyId == _this.specialtyId)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.page, _this.page) || other.page == _this.page)&&(identical(other.pageSize, _this.pageSize) || other.pageSize == _this.pageSize));
}


@override
int get hashCode {
  final _this = this as DoctorQuery;
  return Object.hash(runtimeType,_this.search,_this.specialtyId,_this.city,_this.page,_this.pageSize);
}

@override
String toString() {
  final _this = this as DoctorQuery;
  return 'DoctorQuery(search: ${_this.search}, specialtyId: ${_this.specialtyId}, city: ${_this.city}, page: ${_this.page}, pageSize: ${_this.pageSize})';
}


}

/// @nodoc
abstract mixin class $DoctorQueryCopyWith<$Res>  {
  factory $DoctorQueryCopyWith(DoctorQuery value, $Res Function(DoctorQuery) _then) = _$DoctorQueryCopyWithImpl;
@useResult
$Res call({
 String search, String? specialtyId, String? city, int page, int pageSize
});




}
/// @nodoc
class _$DoctorQueryCopyWithImpl<$Res>
    implements $DoctorQueryCopyWith<$Res> {
  _$DoctorQueryCopyWithImpl(this._self, this._then);

  final DoctorQuery _self;
  final $Res Function(DoctorQuery) _then;

/// Create a copy of DoctorQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? search = null,Object? specialtyId = freezed,Object? city = freezed,Object? page = null,Object? pageSize = null,}) {
  return _then(DoctorQuery(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,specialtyId: freezed == specialtyId ? _self.specialtyId : specialtyId // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DoctorQuery].
extension DoctorQueryPatterns on DoctorQuery {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DoctorQuery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DoctorQuery() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DoctorQuery value)  $default,){
final _that = this;
switch (_that) {
case _DoctorQuery():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DoctorQuery value)?  $default,){
final _that = this;
switch (_that) {
case _DoctorQuery() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String search,  String? specialtyId,  String? city,  int page,  int pageSize)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DoctorQuery() when $default != null:
return $default(_that.search,_that.specialtyId,_that.city,_that.page,_that.pageSize);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String search,  String? specialtyId,  String? city,  int page,  int pageSize)  $default,) {final _that = this;
switch (_that) {
case _DoctorQuery():
return $default(_that.search,_that.specialtyId,_that.city,_that.page,_that.pageSize);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String search,  String? specialtyId,  String? city,  int page,  int pageSize)?  $default,) {final _that = this;
switch (_that) {
case _DoctorQuery() when $default != null:
return $default(_that.search,_that.specialtyId,_that.city,_that.page,_that.pageSize);case _:
  return null;

}
}

}

/// @nodoc


class _DoctorQuery extends DoctorQuery {
  const _DoctorQuery({this.search = '', this.specialtyId, this.city, this.page = 1, this.pageSize = 10}): super._();
  

/// Free-text search over provider name / specialty / city.
@override@JsonKey() final  String search;
/// Specialty id filter, or `null` for "all specialties".
@override final  String? specialtyId;
/// City filter, or `null` for "all cities".
@override final  String? city;
/// 1-based page index.
@override@JsonKey() final  int page;
@override@JsonKey() final  int pageSize;

/// Create a copy of DoctorQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DoctorQueryCopyWith<_DoctorQuery> get copyWith => __$DoctorQueryCopyWithImpl<_DoctorQuery>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DoctorQuery&&(identical(other.search, search) || other.search == search)&&(identical(other.specialtyId, specialtyId) || other.specialtyId == specialtyId)&&(identical(other.city, city) || other.city == city)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize));
}


@override
int get hashCode {
    return Object.hash(runtimeType,search,specialtyId,city,page,pageSize);
}

@override
String toString() {
    return 'DoctorQuery(search: $search, specialtyId: $specialtyId, city: $city, page: $page, pageSize: $pageSize)';
}


}

/// @nodoc
abstract mixin class _$DoctorQueryCopyWith<$Res> implements $DoctorQueryCopyWith<$Res> {
  factory _$DoctorQueryCopyWith(_DoctorQuery value, $Res Function(_DoctorQuery) _then) = __$DoctorQueryCopyWithImpl;
@override @useResult
$Res call({
 String search, String? specialtyId, String? city, int page, int pageSize
});




}
/// @nodoc
class __$DoctorQueryCopyWithImpl<$Res>
    implements _$DoctorQueryCopyWith<$Res> {
  __$DoctorQueryCopyWithImpl(this._self, this._then);

  final _DoctorQuery _self;
  final $Res Function(_DoctorQuery) _then;

/// Create a copy of DoctorQuery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? search = null,Object? specialtyId = freezed,Object? city = freezed,Object? page = null,Object? pageSize = null,}) {
  return _then(_DoctorQuery(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,specialtyId: freezed == specialtyId ? _self.specialtyId : specialtyId // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
