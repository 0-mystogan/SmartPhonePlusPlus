// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartItem _$CartItemFromJson(Map<String, dynamic> json) => CartItem(
      id: json['id'] as int,
      quantity: json['quantity'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      cartId: json['cartId'] as int,
      productId: json['productId'] as int,
      productName: json['productName'] as String,
      productSKU: json['productSKU'] as String?,
      productPrice: (json['productPrice'] as num?)?.toDouble(),
      productImageUrl: json['productImageUrl'] as String?,
      totalPrice: (json['totalPrice'] as num).toDouble(),
    );

Map<String, dynamic> _$CartItemToJson(CartItem instance) => <String, dynamic>{
      'id': instance.id,
      'quantity': instance.quantity,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'cartId': instance.cartId,
      'productId': instance.productId,
      'productName': instance.productName,
      'productSKU': instance.productSKU,
      'productPrice': instance.productPrice,
      'productImageUrl': instance.productImageUrl,
      'totalPrice': instance.totalPrice,
    };
