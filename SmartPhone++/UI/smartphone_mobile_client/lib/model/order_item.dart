import 'package:json_annotation/json_annotation.dart';

part 'order_item.g.dart';

@JsonSerializable()
class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? notes;
  final String productName;
  final String productSKU;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.notes,
    required this.productName,
    required this.productSKU,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);

  String get formattedUnitPrice => '${unitPrice.toStringAsFixed(2)} BAM';
  String get formattedTotalPrice => '${totalPrice.toStringAsFixed(2)} BAM';
}
