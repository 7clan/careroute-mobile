// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'availability.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AvailabilityDay {

/// Calendar day (date only).
 DateTime get date;/// Bookable start times, 24-hour clock, e.g. `09:00`, `09:30`.
 List<String> get slots;
/// Create a copy of AvailabilityDay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AvailabilityDayCopyWith<AvailabilityDay> get copyWith => _$AvailabilityDayCopyWithImpl<AvailabilityDay>(this as AvailabilityDay, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AvailabilityDay;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AvailabilityDay&&(identical(other.date, _this.date) || other.date == _this.date)&&const DeepCollectionEquality().equals(other.slots, _this.slots));
}


@override
int get hashCode {
  final _this = this as AvailabilityDay;
  return Object.hash(runtimeType,_this.date,const DeepCollectionEquality().hash(_this.slots));
}

@override
String toString() {
  final _this = this as AvailabilityDay;
  return 'AvailabilityDay(date: ${_this.date}, slots: ${_this.slots})';
}


}

/// @nodoc
abstract mixin class $AvailabilityDayCopyWith<$Res>  {
  factory $AvailabilityDayCopyWith(AvailabilityDay value, $Res Function(AvailabilityDay) _then) = _$AvailabilityDayCopyWithImpl;
@useResult
$Res call({
 DateTime date, List<String> slots
});




}
/// @nodoc
class _$AvailabilityDayCopyWithImpl<$Res>
    implements $AvailabilityDayCopyWith<$Res> {
  _$AvailabilityDayCopyWithImpl(this._self, this._then);

  final AvailabilityDay _self;
  final $Res Function(AvailabilityDay) _then;

/// Create a copy of AvailabilityDay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? slots = null,}) {
  return _then(AvailabilityDay(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,slots: null == slots ? _self.slots : slots // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [AvailabilityDay].
extension AvailabilityDayPatterns on AvailabilityDay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AvailabilityDay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AvailabilityDay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AvailabilityDay value)  $default,){
final _that = this;
switch (_that) {
case _AvailabilityDay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AvailabilityDay value)?  $default,){
final _that = this;
switch (_that) {
case _AvailabilityDay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  List<String> slots)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AvailabilityDay() when $default != null:
return $default(_that.date,_that.slots);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  List<String> slots)  $default,) {final _that = this;
switch (_that) {
case _AvailabilityDay():
return $default(_that.date,_that.slots);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  List<String> slots)?  $default,) {final _that = this;
switch (_that) {
case _AvailabilityDay() when $default != null:
return $default(_that.date,_that.slots);case _:
  return null;

}
}

}

/// @nodoc


class _AvailabilityDay implements AvailabilityDay {
  const _AvailabilityDay({required this.date,  List<String> slots = const <String>[]}): _slots = slots;
  

/// Calendar day (date only).
@override final  DateTime date;
/// Bookable start times, 24-hour clock, e.g. `09:00`, `09:30`.
 final  List<String> _slots;
/// Bookable start times, 24-hour clock, e.g. `09:00`, `09:30`.
@override@JsonKey() List<String> get slots {
  if (_slots is EqualUnmodifiableListView) return _slots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_slots);
}


/// Create a copy of AvailabilityDay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AvailabilityDayCopyWith<_AvailabilityDay> get copyWith => __$AvailabilityDayCopyWithImpl<_AvailabilityDay>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AvailabilityDay&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other.slots, _slots));
}


@override
int get hashCode {
    return Object.hash(runtimeType,date,const DeepCollectionEquality().hash(_slots));
}

@override
String toString() {
    return 'AvailabilityDay(date: $date, slots: $slots)';
}


}

/// @nodoc
abstract mixin class _$AvailabilityDayCopyWith<$Res> implements $AvailabilityDayCopyWith<$Res> {
  factory _$AvailabilityDayCopyWith(_AvailabilityDay value, $Res Function(_AvailabilityDay) _then) = __$AvailabilityDayCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, List<String> slots
});




}
/// @nodoc
class __$AvailabilityDayCopyWithImpl<$Res>
    implements _$AvailabilityDayCopyWith<$Res> {
  __$AvailabilityDayCopyWithImpl(this._self, this._then);

  final _AvailabilityDay _self;
  final $Res Function(_AvailabilityDay) _then;

/// Create a copy of AvailabilityDay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? slots = null,}) {
  return _then(_AvailabilityDay(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,slots: null == slots ? _self._slots : slots // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
