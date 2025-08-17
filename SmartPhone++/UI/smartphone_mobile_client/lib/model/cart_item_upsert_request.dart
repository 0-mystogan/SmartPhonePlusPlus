import 'package:json_annotation/json_annotation.dart';

part 'cart_item_upsert_request.g.dart';

@JsonSerializable()
class CartItemUpsertRequest {
  final int quantity;
  final int productId;
  final int cartId;

  CartItemUpsertRequest({
    required this.quantity,
    required this.productId,
    required this.cartId,
  });

  factory CartItemUpsertRequest.fromJson(Map<String, dynamic> json) => _$CartItemUpsertRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CartItemUpsertRequestToJson(this);
}
