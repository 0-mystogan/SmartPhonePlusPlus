import 'package:json_annotation/json_annotation.dart';
import 'cart_item.dart';

part 'cart.g.dart';

@JsonSerializable()
class Cart {
  final int id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? expiresAt;
  final bool isActive;
  final int userId;
  final String userName;
  final String userEmail;
  final int totalItems;
  final double totalAmount;
  final List<CartItem>? cartItems;

  Cart({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    this.expiresAt,
    required this.isActive,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.totalItems,
    required this.totalAmount,
    this.cartItems,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);
  Map<String, dynamic> toJson() => _$CartToJson(this);
}
