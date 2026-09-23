// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'specialty.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Specialty {

 String get id; String get name;/// Number of providers currently listed under this specialty.
 int get doctorCount;
/// Create a copy of Specialty
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpecialtyCopyWith<Specialty> get copyWith => _$SpecialtyCopyWithImpl<Specialty>(this as Specialty, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Specialty;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Specialty&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.doctorCount, _this.doctorCount) || other.doctorCount == _this.doctorCount));
}


@override
int get hashCode {
  final _this = this as Specialty;
  return Object.hash(runtimeType,_this.id,_this.name,_this.doctorCount);
}

@override
String toString() {
  final _this = this as Specialty;
  return 'Specialty(id: ${_this.id}, name: ${_this.name}, doctorCount: ${_this.doctorCount})';
}


}

/// @nodoc
abstract mixin class $SpecialtyCopyWith<$Res>  {
  factory $SpecialtyCopyWith(Specialty value, $Res Function(Specialty) _then) = _$SpecialtyCopyWithImpl;
@useResult
$Res call({
 String id, String name, int doctorCount
});




}
/// @nodoc
class _$SpecialtyCopyWithImpl<$Res>
    implements $SpecialtyCopyWith<$Res> {
  _$SpecialtyCopyWithImpl(this._self, this._then);

  final Specialty _self;
  final $Res Function(Specialty) _then;

/// Create a copy of Specialty
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? doctorCount = null,}) {
  return _then(Specialty(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,doctorCount: null == doctorCount ? _self.doctorCount : doctorCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Specialty].
extension SpecialtyPatterns on Specialty {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Specialty value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Specialty() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Specialty value)  $default,){
final _that = this;
switch (_that) {
case _Specialty():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Specialty value)?  $default,){
final _that = this;
switch (_that) {
case _Specialty() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  int doctorCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Specialty() when $default != null:
return $default(_that.id,_that.name,_that.doctorCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  int doctorCount)  $default,) {final _that = this;
switch (_that) {
case _Specialty():
return $default(_that.id,_that.name,_that.doctorCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  int doctorCount)?  $default,) {final _that = this;
switch (_that) {
case _Specialty() when $default != null:
return $default(_that.id,_that.name,_that.doctorCount);case _:
  return null;

}
}

}

/// @nodoc


class _Specialty implements Specialty {
  const _Specialty({required this.id, required this.name, required this.doctorCount});
  

@override final  String id;
@override final  String name;
/// Number of providers currently listed under this specialty.
@override final  int doctorCount;

/// Create a copy of Specialty
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpecialtyCopyWith<_Specialty> get copyWith => __$SpecialtyCopyWithImpl<_Specialty>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Specialty&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.doctorCount, doctorCount) || other.doctorCount == doctorCount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,doctorCount);
}

@override
String toString() {
    return 'Specialty(id: $id, name: $name, doctorCount: $doctorCount)';
}


}

/// @nodoc
abstract mixin class _$SpecialtyCopyWith<$Res> implements $SpecialtyCopyWith<$Res> {
  factory _$SpecialtyCopyWith(_Specialty value, $Res Function(_Specialty) _then) = __$SpecialtyCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int doctorCount
});




}
/// @nodoc
class __$SpecialtyCopyWithImpl<$Res>
    implements _$SpecialtyCopyWith<$Res> {
  __$SpecialtyCopyWithImpl(this._self, this._then);

  final _Specialty _self;
  final $Res Function(_Specialty) _then;

/// Create a copy of Specialty
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? doctorCount = null,}) {
  return _then(_Specialty(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,doctorCount: null == doctorCount ? _self.doctorCount : doctorCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
