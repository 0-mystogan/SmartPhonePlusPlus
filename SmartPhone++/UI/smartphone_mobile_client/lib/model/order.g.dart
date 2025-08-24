// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
      id: json['id'] as int,
      orderNumber: json['orderNumber'] as String,
      orderDate: DateTime.parse(json['orderDate'] as String),
      shippedDate: json['shippedDate'] == null
          ? null
          : DateTime.parse(json['shippedDate'] as String),
      deliveredDate: json['deliveredDate'] == null
          ? null
          : DateTime.parse(json['deliveredDate'] as String),
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
      userName: json['userName'] as String,
      orderItems: (json['orderItems'] as List<dynamic>?)
          ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'id': instance.id,
      'orderNumber': instance.orderNumber,
      'orderDate': instance.orderDate.toIso8601String(),
      'shippedDate': instance.shippedDate?.toIso8601String(),
      'deliveredDate': instance.deliveredDate?.toIso8601String(),
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
      'userName': instance.userName,
      'orderItems': instance.orderItems?.map((e) => e.toJson()).toList(),
    };
