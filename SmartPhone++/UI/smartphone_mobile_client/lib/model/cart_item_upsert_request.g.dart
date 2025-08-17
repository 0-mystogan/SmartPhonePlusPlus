// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item_upsert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartItemUpsertRequest _$CartItemUpsertRequestFromJson(
        Map<String, dynamic> json) =>
    CartItemUpsertRequest(
      quantity: json['quantity'] as int,
      productId: json['productId'] as int,
      cartId: json['cartId'] as int,
    );

Map<String, dynamic> _$CartItemUpsertRequestToJson(
        CartItemUpsertRequest instance) =>
    <String, dynamic>{
      'quantity': instance.quantity,
      'productId': instance.productId,
      'cartId': instance.cartId,
    };
