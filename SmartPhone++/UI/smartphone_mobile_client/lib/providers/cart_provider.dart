import 'package:smartphone_mobile_client/model/cart.dart';
import 'package:smartphone_mobile_client/model/cart_upsert_request.dart';
import 'package:smartphone_mobile_client/model/cart_item_operation_request.dart';
import 'package:smartphone_mobile_client/model/search_result.dart';
import 'package:smartphone_mobile_client/providers/base_provider.dart';

class CartProvider extends BaseProvider<Cart> {
  CartProvider() : super("Cart");

  @override
  Cart fromJson(dynamic data) {
    return Cart.fromJson(data);
  }

  /// Get the current user's cart
  Future<Cart?> getMyCart(int userId) async {
    try {
      final response = await get(filter: {'userId': userId});
      if (response.items != null && response.items!.isNotEmpty) {
        return response.items!.first;
      }
      return null;
    } catch (e) {
      print('Error getting my cart: $e');
      rethrow;
    }
  }

  /// Get cart by user ID (for admin purposes)
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

  /// Add item to cart using the new unified endpoint
  Future<Cart> addItemToCart(CartItemOperationRequest request) async {
    try {
      final response = await postCustom('add', request.toJson());
      if (response != null) {
        return Cart.fromJson(response);
      }
      throw Exception('Failed to add item to cart');
    } catch (e) {
      print('Error adding item to cart: $e');
      rethrow;
    }
  }

  /// Update item quantity using the new unified endpoint
  Future<Cart> updateItemQuantity(CartItemOperationRequest request) async {
    try {
      final response = await putCustom('update', request.toJson());
      if (response != null) {
        return Cart.fromJson(response);
      }
      throw Exception('Failed to update item quantity');
    } catch (e) {
      print('Error updating item quantity: $e');
      rethrow;
    }
  }

  /// Remove item from cart using the new unified endpoint
  Future<Cart> removeItemFromCart(CartItemOperationRequest request) async {
    try {
      print('CartProvider: Attempting to remove item with ProductId: ${request.productId}');
      final response = await postCustom('remove', request.toJson());
      if (response != null) {
        print('CartProvider: Successfully removed item, response: $response');
        return Cart.fromJson(response);
      }
      throw Exception('Failed to remove item to cart');
    } catch (e) {
      print('CartProvider: Error removing item from cart: $e');
      print('CartProvider: Request data: ${request.toJson()}');
      rethrow;
    }
  }

  /// Clear cart
  Future<void> clearCart() async {
    try {
      await deleteCustom('clear');
    } catch (e) {
      print('Error clearing cart: $e');
      rethrow;
    }
  }
}
