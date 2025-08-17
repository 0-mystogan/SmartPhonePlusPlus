// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cart _$CartFromJson(Map<String, dynamic> json) => Cart(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      isActive: json['isActive'] as bool,
      userId: json['userId'] as int,
      userName: json['userName'] as String,
      userEmail: json['userEmail'] as String,
      totalItems: json['totalItems'] as int,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      cartItems: (json['cartItems'] as List<dynamic>?)
          ?.map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CartToJson(Cart instance) => <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'isActive': instance.isActive,
      'userId': instance.userId,
      'userName': instance.userName,
      'userEmail': instance.userEmail,
      'totalItems': instance.totalItems,
      'totalAmount': instance.totalAmount,
      'cartItems': instance.cartItems,
    };
