// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'doctor_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DoctorPage {

 List<Doctor> get items; int get page; int get pageSize;/// Total number of providers matching the query (all pages).
 int get totalCount; int get totalPages;
/// Create a copy of DoctorPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DoctorPageCopyWith<DoctorPage> get copyWith => _$DoctorPageCopyWithImpl<DoctorPage>(this as DoctorPage, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DoctorPage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DoctorPage&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.page, _this.page) || other.page == _this.page)&&(identical(other.pageSize, _this.pageSize) || other.pageSize == _this.pageSize)&&(identical(other.totalCount, _this.totalCount) || other.totalCount == _this.totalCount)&&(identical(other.totalPages, _this.totalPages) || other.totalPages == _this.totalPages));
}


@override
int get hashCode {
  final _this = this as DoctorPage;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.items),_this.page,_this.pageSize,_this.totalCount,_this.totalPages);
}

@override
String toString() {
  final _this = this as DoctorPage;
  return 'DoctorPage(items: ${_this.items}, page: ${_this.page}, pageSize: ${_this.pageSize}, totalCount: ${_this.totalCount}, totalPages: ${_this.totalPages})';
}


}

/// @nodoc
abstract mixin class $DoctorPageCopyWith<$Res>  {
  factory $DoctorPageCopyWith(DoctorPage value, $Res Function(DoctorPage) _then) = _$DoctorPageCopyWithImpl;
@useResult
$Res call({
 List<Doctor> items, int page, int pageSize, int totalCount, int totalPages
});




}
/// @nodoc
class _$DoctorPageCopyWithImpl<$Res>
    implements $DoctorPageCopyWith<$Res> {
  _$DoctorPageCopyWithImpl(this._self, this._then);

  final DoctorPage _self;
  final $Res Function(DoctorPage) _then;

/// Create a copy of DoctorPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? page = null,Object? pageSize = null,Object? totalCount = null,Object? totalPages = null,}) {
  return _then(DoctorPage(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Doctor>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DoctorPage].
extension DoctorPagePatterns on DoctorPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DoctorPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DoctorPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DoctorPage value)  $default,){
final _that = this;
switch (_that) {
case _DoctorPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DoctorPage value)?  $default,){
final _that = this;
switch (_that) {
case _DoctorPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Doctor> items,  int page,  int pageSize,  int totalCount,  int totalPages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DoctorPage() when $default != null:
return $default(_that.items,_that.page,_that.pageSize,_that.totalCount,_that.totalPages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Doctor> items,  int page,  int pageSize,  int totalCount,  int totalPages)  $default,) {final _that = this;
switch (_that) {
case _DoctorPage():
return $default(_that.items,_that.page,_that.pageSize,_that.totalCount,_that.totalPages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Doctor> items,  int page,  int pageSize,  int totalCount,  int totalPages)?  $default,) {final _that = this;
switch (_that) {
case _DoctorPage() when $default != null:
return $default(_that.items,_that.page,_that.pageSize,_that.totalCount,_that.totalPages);case _:
  return null;

}
}

}

/// @nodoc


class _DoctorPage extends DoctorPage {
  const _DoctorPage({required  List<Doctor> items, required this.page, required this.pageSize, required this.totalCount, required this.totalPages}): _items = items,super._();
  

 final  List<Doctor> _items;
@override List<Doctor> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int page;
@override final  int pageSize;
/// Total number of providers matching the query (all pages).
@override final  int totalCount;
@override final  int totalPages;

/// Create a copy of DoctorPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DoctorPageCopyWith<_DoctorPage> get copyWith => __$DoctorPageCopyWithImpl<_DoctorPage>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DoctorPage&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),page,pageSize,totalCount,totalPages);
}

@override
String toString() {
    return 'DoctorPage(items: $items, page: $page, pageSize: $pageSize, totalCount: $totalCount, totalPages: $totalPages)';
}


}

/// @nodoc
abstract mixin class _$DoctorPageCopyWith<$Res> implements $DoctorPageCopyWith<$Res> {
  factory _$DoctorPageCopyWith(_DoctorPage value, $Res Function(_DoctorPage) _then) = __$DoctorPageCopyWithImpl;
@override @useResult
$Res call({
 List<Doctor> items, int page, int pageSize, int totalCount, int totalPages
});




}
/// @nodoc
class __$DoctorPageCopyWithImpl<$Res>
    implements _$DoctorPageCopyWith<$Res> {
  __$DoctorPageCopyWithImpl(this._self, this._then);

  final _DoctorPage _self;
  final $Res Function(_DoctorPage) _then;

/// Create a copy of DoctorPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? page = null,Object? pageSize = null,Object? totalCount = null,Object? totalPages = null,}) {
  return _then(_DoctorPage(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Doctor>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
