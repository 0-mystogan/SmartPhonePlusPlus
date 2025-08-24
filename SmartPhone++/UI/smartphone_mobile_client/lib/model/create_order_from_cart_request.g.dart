// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_order_from_cart_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateOrderFromCartRequest _$CreateOrderFromCartRequestFromJson(
        Map<String, dynamic> json) =>
    CreateOrderFromCartRequest(
      orderNumber: json['orderNumber'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      shippingFirstName: json['shippingFirstName'] as String,
      shippingLastName: json['shippingLastName'] as String,
      shippingAddress: json['shippingAddress'] as String,
      shippingCity: json['shippingCity'] as String,
      shippingPostalCode: json['shippingPostalCode'] as String,
      shippingCountry: json['shippingCountry'] as String,
      shippingPhone: json['shippingPhone'] as String,
      shippingEmail: json['shippingEmail'] as String?,
      billingFirstName: json['billingFirstName'] as String,
      billingLastName: json['billingLastName'] as String,
      billingAddress: json['billingAddress'] as String,
      billingCity: json['billingCity'] as String,
      billingPostalCode: json['billingPostalCode'] as String,
      billingCountry: json['billingCountry'] as String,
      billingPhone: json['billingPhone'] as String,
      billingEmail: json['billingEmail'] as String?,
    );

Map<String, dynamic> _$CreateOrderFromCartRequestToJson(
        CreateOrderFromCartRequest instance) =>
    <String, dynamic>{
      'orderNumber': instance.orderNumber,
      'totalAmount': instance.totalAmount,
      'shippingFirstName': instance.shippingFirstName,
      'shippingLastName': instance.shippingLastName,
      'shippingAddress': instance.shippingAddress,
      'shippingCity': instance.shippingCity,
      'shippingPostalCode': instance.shippingPostalCode,
      'shippingCountry': instance.shippingCountry,
      'shippingPhone': instance.shippingPhone,
      'shippingEmail': instance.shippingEmail,
      'billingFirstName': instance.billingFirstName,
      'billingLastName': instance.billingLastName,
      'billingAddress': instance.billingAddress,
      'billingCity': instance.billingCity,
      'billingPostalCode': instance.billingPostalCode,
      'billingCountry': instance.billingCountry,
      'billingPhone': instance.billingPhone,
      'billingEmail': instance.billingEmail,
    };
