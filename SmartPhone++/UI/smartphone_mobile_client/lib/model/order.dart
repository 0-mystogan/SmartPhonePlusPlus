import 'package:json_annotation/json_annotation.dart';
import 'order_item.dart';

part 'order.g.dart';

@JsonSerializable()
class Order {
  final int id;
  final String orderNumber;
  final DateTime orderDate;
  final DateTime? shippedDate;
  final DateTime? deliveredDate;
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
  final String userName;
  final List<OrderItem>? orderItems;

  Order({
    required this.id,
    required this.orderNumber,
    required this.orderDate,
    this.shippedDate,
    this.deliveredDate,
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
    required this.userName,
    this.orderItems,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);

  String get fullShippingName => '$shippingFirstName $shippingLastName';
  String get fullBillingName => '$billingFirstName $billingLastName';
  String get formattedOrderDate => '${orderDate.day}/${orderDate.month}/${orderDate.year}';
  String get formattedTotalAmount => '${totalAmount.toStringAsFixed(2)} BAM';
  
  bool get isShipped => status == 'Shipped';
  bool get isDelivered => status == 'Delivered';
  bool get isProcessing => status == 'Processing';
  bool get isPending => status == 'Pending';
  bool get isCancelled => status == 'Cancelled';
}
