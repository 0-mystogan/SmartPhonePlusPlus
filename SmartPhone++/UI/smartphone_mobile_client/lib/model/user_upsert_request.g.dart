// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_upsert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserUpsertRequest _$UserUpsertRequestFromJson(Map<String, dynamic> json) =>
    UserUpsertRequest(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      picture: json['picture'] as String?,
      email: json['email'] as String,
      username: json['username'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      genderId: json['genderId'] as int,
      cityId: json['cityId'] as int,
      isActive: json['isActive'] as bool? ?? true,
      password: json['password'] as String?,
      roleIds: (json['roleIds'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$UserUpsertRequestToJson(UserUpsertRequest instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'picture': instance.picture,
      'email': instance.email,
      'username': instance.username,
      'phoneNumber': instance.phoneNumber,
      'genderId': instance.genderId,
      'cityId': instance.cityId,
      'isActive': instance.isActive,
      'password': instance.password,
      'roleIds': instance.roleIds,
    };
