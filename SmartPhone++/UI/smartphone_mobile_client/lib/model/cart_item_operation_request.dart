class CartItemOperationRequest {
  final int productId;
  final int quantity;

  CartItemOperationRequest({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}
