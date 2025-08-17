import 'package:smartphone_mobile_client/model/cart.dart';
import 'package:smartphone_mobile_client/model/cart_upsert_request.dart';
import 'package:smartphone_mobile_client/model/search_result.dart';
import 'package:smartphone_mobile_client/providers/base_provider.dart';

class CartProvider extends BaseProvider<Cart> {
  CartProvider() : super("Cart");

  @override
  Cart fromJson(dynamic data) {
    return Cart.fromJson(data);
  }

  Future<Cart?> getByUserId(int userId) async {
    try {
      final response = await get(filter: {'userId': userId});
      if (response.items != null && response.items!.isNotEmpty) {
        return response.items!.first;
      }
      return null;
    } catch (e) {
      print('Error getting cart by user ID: $e');
      rethrow;
    }
  }

  Future<Cart> createCart(CartUpsertRequest request) async {
    try {
      return await insert(request.toJson());
    } catch (e) {
      print('Error creating cart: $e');
      rethrow;
    }
  }

  Future<Cart> updateCart(int cartId, CartUpsertRequest request) async {
    try {
      return await update(cartId, request.toJson());
    } catch (e) {
      print('Error updating cart: $e');
      rethrow;
    }
  }

  Future<bool> deleteCart(int cartId) async {
    try {
      await delete(cartId);
      return true;
    } catch (e) {
      print('Error deleting cart: $e');
      return false;
    }
  }
}
