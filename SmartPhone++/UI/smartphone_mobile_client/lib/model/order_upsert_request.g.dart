// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_upsert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderUpsertRequest _$OrderUpsertRequestFromJson(Map<String, dynamic> json) => OrderUpsertRequest(
      orderNumber: json['orderNumber'] as String,
      subtotal: (json['subtotal'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      shippingAmount: (json['shippingAmount'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      trackingNumber: json['trackingNumber'] as String?,
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
      userId: json['userId'] as int,
    );

Map<String, dynamic> _$OrderUpsertRequestToJson(OrderUpsertRequest instance) => <String, dynamic>{
      'orderNumber': instance.orderNumber,
      'subtotal': instance.subtotal,
      'taxAmount': instance.taxAmount,
      'shippingAmount': instance.shippingAmount,
      'discountAmount': instance.discountAmount,
      'totalAmount': instance.totalAmount,
      'status': instance.status,
      'notes': instance.notes,
      'trackingNumber': instance.trackingNumber,
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
      'userId': instance.userId,
    };
