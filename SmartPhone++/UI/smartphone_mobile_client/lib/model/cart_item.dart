import 'package:json_annotation/json_annotation.dart';

part 'cart_item.g.dart';

@JsonSerializable()
class CartItem {
  final int id;
  final int quantity;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int cartId;
  final int productId;
  final String productName;
  final String? productSKU;
  final double? productPrice;
  final String? productImageUrl;
  final double totalPrice;
  // Category information for recommendations
  final int? productCategoryId;
  final String? productCategoryName;

  CartItem({
    required this.id,
    required this.quantity,
    required this.createdAt,
    this.updatedAt,
    required this.cartId,
    required this.productId,
    required this.productName,
    this.productSKU,
    this.productPrice,
    this.productImageUrl,
    required this.totalPrice,
    this.productCategoryId,
    this.productCategoryName,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => _$CartItemFromJson(json);
  Map<String, dynamic> toJson() => _$CartItemToJson(this);

  CartItem copyWith({
    int? id,
    int? quantity,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? cartId,
    int? productId,
    String? productName,
    String? productSKU,
    double? productPrice,
    String? productImageUrl,
    double? totalPrice,
    int? productCategoryId,
    String? productCategoryName,
  }) {
    return CartItem(
      id: id ?? this.id,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cartId: cartId ?? this.cartId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productSKU: productSKU ?? this.productSKU,
      productPrice: productPrice ?? this.productPrice,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      totalPrice: totalPrice ?? this.totalPrice,
      productCategoryId: productCategoryId ?? this.productCategoryId,
      productCategoryName: productCategoryName ?? this.productCategoryName,
    );
  }
}
