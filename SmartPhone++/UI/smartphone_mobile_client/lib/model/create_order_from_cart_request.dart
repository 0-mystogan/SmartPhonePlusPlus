import 'package:json_annotation/json_annotation.dart';

part 'create_order_from_cart_request.g.dart';

@JsonSerializable()
class CreateOrderFromCartRequest {
  final String orderNumber;
  final num totalAmount;
  
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

  CreateOrderFromCartRequest({
    required this.orderNumber,
    required this.totalAmount,
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
  });

  factory CreateOrderFromCartRequest.fromJson(Map<String, dynamic> json) => 
      _$CreateOrderFromCartRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateOrderFromCartRequestToJson(this);
}
