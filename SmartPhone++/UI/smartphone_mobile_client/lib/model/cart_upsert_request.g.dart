// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_upsert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartUpsertRequest _$CartUpsertRequestFromJson(Map<String, dynamic> json) =>
    CartUpsertRequest(
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      userId: json['userId'] as int,
    );

Map<String, dynamic> _$CartUpsertRequestToJson(CartUpsertRequest instance) =>
    <String, dynamic>{
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'isActive': instance.isActive,
      'userId': instance.userId,
    };
