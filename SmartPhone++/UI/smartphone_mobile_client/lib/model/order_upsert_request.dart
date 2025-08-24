import 'package:json_annotation/json_annotation.dart';

part 'order_upsert_request.g.dart';

@JsonSerializable()
class OrderUpsertRequest {
  final String orderNumber;
  final double subtotal;
  final double taxAmount;
  final double shippingAmount;
  final double discountAmount;
  final double totalAmount;
  final String status;
  final String? notes;
  final String? trackingNumber;
  
  // Shipping information
  final String shippingFirstName;
  final String shippingLastName;
  final String shippingAddress;
  final String shippingCity;
  final String shippingPostalCode;
  final String shippingCountry;
  final String shippingPhone;
  final String? shippingEmail;
  
  // Billing information
  final String billingFirstName;
  final String billingLastName;
  final String billingAddress;
  final String billingCity;
  final String billingPostalCode;
  final String billingCountry;
  final String billingPhone;
  final String? billingEmail;
  
  final int userId;

  OrderUpsertRequest({
    required this.orderNumber,
    required this.subtotal,
    required this.taxAmount,
    required this.shippingAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.status,
    this.notes,
    this.trackingNumber,
    required this.shippingFirstName,
    required this.shippingLastName,
    required this.shippingAddress,
    required this.shippingCity,
    required this.shippingPostalCode,
    required this.shippingCountry,
    required this.shippingPhone,
    this.shippingEmail,
    required this.billingFirstName,
    required this.billingLastName,
    required this.billingAddress,
    required this.billingCity,
    required this.billingPostalCode,
    required this.billingCountry,
    required this.billingPhone,
    this.billingEmail,
    required this.userId,
  });

  factory OrderUpsertRequest.fromJson(Map<String, dynamic> json) => 
      _$OrderUpsertRequestFromJson(json);
  Map<String, dynamic> toJson() => _$OrderUpsertRequestToJson(this);
}
