import 'package:smartphone_mobile_client/model/cart_item.dart';
import 'package:smartphone_mobile_client/model/cart_item_upsert_request.dart';
import 'package:smartphone_mobile_client/model/search_result.dart';
import 'package:smartphone_mobile_client/providers/base_provider.dart';

class CartItemProvider extends BaseProvider<CartItem> {
  CartItemProvider() : super("CartItem");

  @override
  CartItem fromJson(dynamic data) {
    return CartItem.fromJson(data);
  }

  Future<List<CartItem>> getByCartId(int cartId) async {
    try {
      final response = await get(filter: {'cartId': cartId});
      return response.items ?? [];
    } catch (e) {
      print('Error getting cart items by cart ID: $e');
      rethrow;
    }
  }

  Future<CartItem> addToCart(CartItemUpsertRequest request) async {
    try {
      return await insert(request.toJson());
    } catch (e) {
      print('Error adding item to cart: $e');
      rethrow;
    }
  }

  Future<CartItem> updateCartItem(int cartItemId, CartItemUpsertRequest request) async {
    try {
      return await update(cartItemId, request.toJson());
    } catch (e) {
      print('Error updating cart item: $e');
      rethrow;
    }
  }

  Future<bool> removeFromCart(int cartItemId) async {
    try {
      await delete(cartItemId);
      return true;
    } catch (e) {
      print('Error removing item from cart: $e');
      return false;
    }
  }

  Future<bool> updateQuantity(int cartItemId, int newQuantity) async {
    try {
      // Get the existing cart item first to preserve other properties
      final existingItem = await getById(cartItemId);
      if (existingItem == null) {
        throw Exception('Cart item not found');
      }
      
      final request = CartItemUpsertRequest(
        quantity: newQuantity,
        productId: existingItem.productId,
        cartId: existingItem.cartId,
      );
      await update(cartItemId, request.toJson());
      return true;
    } catch (e) {
      print('Error updating quantity: $e');
      return false;
    }
  }
}
