// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'doctor.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WeeklySession {

 String get day; String get from; String get to;
/// Create a copy of WeeklySession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeeklySessionCopyWith<WeeklySession> get copyWith => _$WeeklySessionCopyWithImpl<WeeklySession>(this as WeeklySession, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WeeklySession;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeeklySession&&(identical(other.day, _this.day) || other.day == _this.day)&&(identical(other.from, _this.from) || other.from == _this.from)&&(identical(other.to, _this.to) || other.to == _this.to));
}


@override
int get hashCode {
  final _this = this as WeeklySession;
  return Object.hash(runtimeType,_this.day,_this.from,_this.to);
}

@override
String toString() {
  final _this = this as WeeklySession;
  return 'WeeklySession(day: ${_this.day}, from: ${_this.from}, to: ${_this.to})';
}


}

/// @nodoc
abstract mixin class $WeeklySessionCopyWith<$Res>  {
  factory $WeeklySessionCopyWith(WeeklySession value, $Res Function(WeeklySession) _then) = _$WeeklySessionCopyWithImpl;
@useResult
$Res call({
 String day, String from, String to
});




}
/// @nodoc
class _$WeeklySessionCopyWithImpl<$Res>
    implements $WeeklySessionCopyWith<$Res> {
  _$WeeklySessionCopyWithImpl(this._self, this._then);

  final WeeklySession _self;
  final $Res Function(WeeklySession) _then;

/// Create a copy of WeeklySession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? day = null,Object? from = null,Object? to = null,}) {
  return _then(WeeklySession(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as String,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WeeklySession].
extension WeeklySessionPatterns on WeeklySession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeeklySession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeeklySession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeeklySession value)  $default,){
final _that = this;
switch (_that) {
case _WeeklySession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeeklySession value)?  $default,){
final _that = this;
switch (_that) {
case _WeeklySession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String day,  String from,  String to)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeeklySession() when $default != null:
return $default(_that.day,_that.from,_that.to);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String day,  String from,  String to)  $default,) {final _that = this;
switch (_that) {
case _WeeklySession():
return $default(_that.day,_that.from,_that.to);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String day,  String from,  String to)?  $default,) {final _that = this;
switch (_that) {
case _WeeklySession() when $default != null:
return $default(_that.day,_that.from,_that.to);case _:
  return null;

}
}

}

/// @nodoc


class _WeeklySession implements WeeklySession {
  const _WeeklySession({required this.day, required this.from, required this.to});
  

@override final  String day;
@override final  String from;
@override final  String to;

/// Create a copy of WeeklySession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeeklySessionCopyWith<_WeeklySession> get copyWith => __$WeeklySessionCopyWithImpl<_WeeklySession>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeeklySession&&(identical(other.day, day) || other.day == day)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to));
}


@override
int get hashCode {
    return Object.hash(runtimeType,day,from,to);
}

@override
String toString() {
    return 'WeeklySession(day: $day, from: $from, to: $to)';
}


}

/// @nodoc
abstract mixin class _$WeeklySessionCopyWith<$Res> implements $WeeklySessionCopyWith<$Res> {
  factory _$WeeklySessionCopyWith(_WeeklySession value, $Res Function(_WeeklySession) _then) = __$WeeklySessionCopyWithImpl;
@override @useResult
$Res call({
 String day, String from, String to
});




}
/// @nodoc
class __$WeeklySessionCopyWithImpl<$Res>
    implements _$WeeklySessionCopyWith<$Res> {
  __$WeeklySessionCopyWithImpl(this._self, this._then);

  final _WeeklySession _self;
  final $Res Function(_WeeklySession) _then;

/// Create a copy of WeeklySession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? day = null,Object? from = null,Object? to = null,}) {
  return _then(_WeeklySession(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as String,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$Doctor {

 String get id; String get name; String get specialtyId; String get specialtyName; String get city; String get address; double get rating; int get reviewCount; int get experienceYears; double get consultationFee; List<String> get languages; List<String> get education; String get bio; String get photoUrl;/// Nearest future moment the provider can be seen, if known.
 DateTime? get nextAvailableAt;/// Populated only by [DoctorRepository.fetchDoctorDetail];
/// list responses leave this empty to keep payloads light.
 bool get isAcceptingNewPatients;/// Recurring weekly session blocks (detail responses only).
 List<WeeklySession> get sessions;
/// Create a copy of Doctor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DoctorCopyWith<Doctor> get copyWith => _$DoctorCopyWithImpl<Doctor>(this as Doctor, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Doctor;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Doctor&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.specialtyId, _this.specialtyId) || other.specialtyId == _this.specialtyId)&&(identical(other.specialtyName, _this.specialtyName) || other.specialtyName == _this.specialtyName)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.rating, _this.rating) || other.rating == _this.rating)&&(identical(other.reviewCount, _this.reviewCount) || other.reviewCount == _this.reviewCount)&&(identical(other.experienceYears, _this.experienceYears) || other.experienceYears == _this.experienceYears)&&(identical(other.consultationFee, _this.consultationFee) || other.consultationFee == _this.consultationFee)&&const DeepCollectionEquality().equals(other.languages, _this.languages)&&const DeepCollectionEquality().equals(other.education, _this.education)&&(identical(other.bio, _this.bio) || other.bio == _this.bio)&&(identical(other.photoUrl, _this.photoUrl) || other.photoUrl == _this.photoUrl)&&(identical(other.nextAvailableAt, _this.nextAvailableAt) || other.nextAvailableAt == _this.nextAvailableAt)&&(identical(other.isAcceptingNewPatients, _this.isAcceptingNewPatients) || other.isAcceptingNewPatients == _this.isAcceptingNewPatients)&&const DeepCollectionEquality().equals(other.sessions, _this.sessions));
}


@override
int get hashCode {
  final _this = this as Doctor;
  return Object.hash(runtimeType,_this.id,_this.name,_this.specialtyId,_this.specialtyName,_this.city,_this.address,_this.rating,_this.reviewCount,_this.experienceYears,_this.consultationFee,const DeepCollectionEquality().hash(_this.languages),const DeepCollectionEquality().hash(_this.education),_this.bio,_this.photoUrl,_this.nextAvailableAt,_this.isAcceptingNewPatients,const DeepCollectionEquality().hash(_this.sessions));
}

@override
String toString() {
  final _this = this as Doctor;
  return 'Doctor(id: ${_this.id}, name: ${_this.name}, specialtyId: ${_this.specialtyId}, specialtyName: ${_this.specialtyName}, city: ${_this.city}, address: ${_this.address}, rating: ${_this.rating}, reviewCount: ${_this.reviewCount}, experienceYears: ${_this.experienceYears}, consultationFee: ${_this.consultationFee}, languages: ${_this.languages}, education: ${_this.education}, bio: ${_this.bio}, photoUrl: ${_this.photoUrl}, nextAvailableAt: ${_this.nextAvailableAt}, isAcceptingNewPatients: ${_this.isAcceptingNewPatients}, sessions: ${_this.sessions})';
}


}

/// @nodoc
abstract mixin class $DoctorCopyWith<$Res>  {
  factory $DoctorCopyWith(Doctor value, $Res Function(Doctor) _then) = _$DoctorCopyWithImpl;
@useResult
$Res call({
 String id, String name, String specialtyId, String specialtyName, String city, String address, double rating, int reviewCount, int experienceYears, double consultationFee, List<String> languages, List<String> education, String bio, String photoUrl, DateTime? nextAvailableAt, bool isAcceptingNewPatients, List<WeeklySession> sessions
});




}
/// @nodoc
class _$DoctorCopyWithImpl<$Res>
    implements $DoctorCopyWith<$Res> {
  _$DoctorCopyWithImpl(this._self, this._then);

  final Doctor _self;
  final $Res Function(Doctor) _then;

/// Create a copy of Doctor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? specialtyId = null,Object? specialtyName = null,Object? city = null,Object? address = null,Object? rating = null,Object? reviewCount = null,Object? experienceYears = null,Object? consultationFee = null,Object? languages = null,Object? education = null,Object? bio = null,Object? photoUrl = null,Object? nextAvailableAt = freezed,Object? isAcceptingNewPatients = null,Object? sessions = null,}) {
  return _then(Doctor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,specialtyId: null == specialtyId ? _self.specialtyId : specialtyId // ignore: cast_nullable_to_non_nullable
as String,specialtyName: null == specialtyName ? _self.specialtyName : specialtyName // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,experienceYears: null == experienceYears ? _self.experienceYears : experienceYears // ignore: cast_nullable_to_non_nullable
as int,consultationFee: null == consultationFee ? _self.consultationFee : consultationFee // ignore: cast_nullable_to_non_nullable
as double,languages: null == languages ? _self.languages : languages // ignore: cast_nullable_to_non_nullable
as List<String>,education: null == education ? _self.education : education // ignore: cast_nullable_to_non_nullable
as List<String>,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,photoUrl: null == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String,nextAvailableAt: freezed == nextAvailableAt ? _self.nextAvailableAt : nextAvailableAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isAcceptingNewPatients: null == isAcceptingNewPatients ? _self.isAcceptingNewPatients : isAcceptingNewPatients // ignore: cast_nullable_to_non_nullable
as bool,sessions: null == sessions ? _self.sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<WeeklySession>,
  ));
}

}


/// Adds pattern-matching-related methods to [Doctor].
extension DoctorPatterns on Doctor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Doctor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Doctor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Doctor value)  $default,){
final _that = this;
switch (_that) {
case _Doctor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Doctor value)?  $default,){
final _that = this;
switch (_that) {
case _Doctor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String specialtyId,  String specialtyName,  String city,  String address,  double rating,  int reviewCount,  int experienceYears,  double consultationFee,  List<String> languages,  List<String> education,  String bio,  String photoUrl,  DateTime? nextAvailableAt,  bool isAcceptingNewPatients,  List<WeeklySession> sessions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Doctor() when $default != null:
return $default(_that.id,_that.name,_that.specialtyId,_that.specialtyName,_that.city,_that.address,_that.rating,_that.reviewCount,_that.experienceYears,_that.consultationFee,_that.languages,_that.education,_that.bio,_that.photoUrl,_that.nextAvailableAt,_that.isAcceptingNewPatients,_that.sessions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String specialtyId,  String specialtyName,  String city,  String address,  double rating,  int reviewCount,  int experienceYears,  double consultationFee,  List<String> languages,  List<String> education,  String bio,  String photoUrl,  DateTime? nextAvailableAt,  bool isAcceptingNewPatients,  List<WeeklySession> sessions)  $default,) {final _that = this;
switch (_that) {
case _Doctor():
return $default(_that.id,_that.name,_that.specialtyId,_that.specialtyName,_that.city,_that.address,_that.rating,_that.reviewCount,_that.experienceYears,_that.consultationFee,_that.languages,_that.education,_that.bio,_that.photoUrl,_that.nextAvailableAt,_that.isAcceptingNewPatients,_that.sessions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String specialtyId,  String specialtyName,  String city,  String address,  double rating,  int reviewCount,  int experienceYears,  double consultationFee,  List<String> languages,  List<String> education,  String bio,  String photoUrl,  DateTime? nextAvailableAt,  bool isAcceptingNewPatients,  List<WeeklySession> sessions)?  $default,) {final _that = this;
switch (_that) {
case _Doctor() when $default != null:
return $default(_that.id,_that.name,_that.specialtyId,_that.specialtyName,_that.city,_that.address,_that.rating,_that.reviewCount,_that.experienceYears,_that.consultationFee,_that.languages,_that.education,_that.bio,_that.photoUrl,_that.nextAvailableAt,_that.isAcceptingNewPatients,_that.sessions);case _:
  return null;

}
}

}

/// @nodoc


class _Doctor implements Doctor {
  const _Doctor({required this.id, required this.name, required this.specialtyId, required this.specialtyName, required this.city, required this.address, required this.rating, required this.reviewCount, required this.experienceYears, required this.consultationFee,  List<String> languages = const <String>[],  List<String> education = const <String>[], required this.bio, required this.photoUrl, this.nextAvailableAt, this.isAcceptingNewPatients = false,  List<WeeklySession> sessions = const <WeeklySession>[]}): _languages = languages,_education = education,_sessions = sessions;
  

@override final  String id;
@override final  String name;
@override final  String specialtyId;
@override final  String specialtyName;
@override final  String city;
@override final  String address;
@override final  double rating;
@override final  int reviewCount;
@override final  int experienceYears;
@override final  double consultationFee;
 final  List<String> _languages;
@override@JsonKey() List<String> get languages {
  if (_languages is EqualUnmodifiableListView) return _languages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_languages);
}

 final  List<String> _education;
@override@JsonKey() List<String> get education {
  if (_education is EqualUnmodifiableListView) return _education;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_education);
}

@override final  String bio;
@override final  String photoUrl;
/// Nearest future moment the provider can be seen, if known.
@override final  DateTime? nextAvailableAt;
/// Populated only by [DoctorRepository.fetchDoctorDetail];
/// list responses leave this empty to keep payloads light.
@override@JsonKey() final  bool isAcceptingNewPatients;
/// Recurring weekly session blocks (detail responses only).
 final  List<WeeklySession> _sessions;
/// Recurring weekly session blocks (detail responses only).
@override@JsonKey() List<WeeklySession> get sessions {
  if (_sessions is EqualUnmodifiableListView) return _sessions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sessions);
}


/// Create a copy of Doctor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DoctorCopyWith<_Doctor> get copyWith => __$DoctorCopyWithImpl<_Doctor>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Doctor&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.specialtyId, specialtyId) || other.specialtyId == specialtyId)&&(identical(other.specialtyName, specialtyName) || other.specialtyName == specialtyName)&&(identical(other.city, city) || other.city == city)&&(identical(other.address, address) || other.address == address)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.experienceYears, experienceYears) || other.experienceYears == experienceYears)&&(identical(other.consultationFee, consultationFee) || other.consultationFee == consultationFee)&&const DeepCollectionEquality().equals(other.languages, _languages)&&const DeepCollectionEquality().equals(other.education, _education)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.nextAvailableAt, nextAvailableAt) || other.nextAvailableAt == nextAvailableAt)&&(identical(other.isAcceptingNewPatients, isAcceptingNewPatients) || other.isAcceptingNewPatients == isAcceptingNewPatients)&&const DeepCollectionEquality().equals(other.sessions, _sessions));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,specialtyId,specialtyName,city,address,rating,reviewCount,experienceYears,consultationFee,const DeepCollectionEquality().hash(_languages),const DeepCollectionEquality().hash(_education),bio,photoUrl,nextAvailableAt,isAcceptingNewPatients,const DeepCollectionEquality().hash(_sessions));
}

@override
String toString() {
    return 'Doctor(id: $id, name: $name, specialtyId: $specialtyId, specialtyName: $specialtyName, city: $city, address: $address, rating: $rating, reviewCount: $reviewCount, experienceYears: $experienceYears, consultationFee: $consultationFee, languages: $languages, education: $education, bio: $bio, photoUrl: $photoUrl, nextAvailableAt: $nextAvailableAt, isAcceptingNewPatients: $isAcceptingNewPatients, sessions: $sessions)';
}


}

/// @nodoc
abstract mixin class _$DoctorCopyWith<$Res> implements $DoctorCopyWith<$Res> {
  factory _$DoctorCopyWith(_Doctor value, $Res Function(_Doctor) _then) = __$DoctorCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String specialtyId, String specialtyName, String city, String address, double rating, int reviewCount, int experienceYears, double consultationFee, List<String> languages, List<String> education, String bio, String photoUrl, DateTime? nextAvailableAt, bool isAcceptingNewPatients, List<WeeklySession> sessions
});




}
/// @nodoc
class __$DoctorCopyWithImpl<$Res>
    implements _$DoctorCopyWith<$Res> {
  __$DoctorCopyWithImpl(this._self, this._then);

  final _Doctor _self;
  final $Res Function(_Doctor) _then;

/// Create a copy of Doctor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? specialtyId = null,Object? specialtyName = null,Object? city = null,Object? address = null,Object? rating = null,Object? reviewCount = null,Object? experienceYears = null,Object? consultationFee = null,Object? languages = null,Object? education = null,Object? bio = null,Object? photoUrl = null,Object? nextAvailableAt = freezed,Object? isAcceptingNewPatients = null,Object? sessions = null,}) {
  return _then(_Doctor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,specialtyId: null == specialtyId ? _self.specialtyId : specialtyId // ignore: cast_nullable_to_non_nullable
as String,specialtyName: null == specialtyName ? _self.specialtyName : specialtyName // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,experienceYears: null == experienceYears ? _self.experienceYears : experienceYears // ignore: cast_nullable_to_non_nullable
as int,consultationFee: null == consultationFee ? _self.consultationFee : consultationFee // ignore: cast_nullable_to_non_nullable
as double,languages: null == languages ? _self._languages : languages // ignore: cast_nullable_to_non_nullable
as List<String>,education: null == education ? _self._education : education // ignore: cast_nullable_to_non_nullable
as List<String>,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,photoUrl: null == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String,nextAvailableAt: freezed == nextAvailableAt ? _self.nextAvailableAt : nextAvailableAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isAcceptingNewPatients: null == isAcceptingNewPatients ? _self.isAcceptingNewPatients : isAcceptingNewPatients // ignore: cast_nullable_to_non_nullable
as bool,sessions: null == sessions ? _self._sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<WeeklySession>,
  ));
}


}

// dart format on
