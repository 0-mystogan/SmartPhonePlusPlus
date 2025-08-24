import 'package:smartphone_mobile_client/model/order.dart';
import 'package:smartphone_mobile_client/model/order_upsert_request.dart';
import 'package:smartphone_mobile_client/model/create_order_from_cart_request.dart';
import 'package:smartphone_mobile_client/model/search_result.dart';
import 'package:smartphone_mobile_client/providers/base_provider.dart';

class OrderProvider extends BaseProvider<Order> {
  OrderProvider() : super("Order");

  @override
  Order fromJson(dynamic data) {
    return Order.fromJson(data);
  }

  /// Get the current user's orders
  Future<List<Order>> getMyOrders() async {
    try {
      final response = await getCustom('my-orders');
      if (response != null && response is List) {
        return response.map((item) => Order.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting my orders: $e');
      rethrow;
    }
  }

  /// Get order by order number
  Future<Order?> getOrderByNumber(String orderNumber) async {
    try {
      final response = await getCustom('by-number/$orderNumber');
      if (response != null) {
        return Order.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error getting order by number: $e');
      rethrow;
    }
  }

  /// Create order from cart
  Future<Order> createOrderFromCart(CreateOrderFromCartRequest request) async {
    try {
      final response = await postCustom('create-from-cart', request.toJson());
      if (response != null) {
        return Order.fromJson(response);
      }
      throw Exception('Failed to create order from cart');
    } catch (e) {
      print('Error creating order from cart: $e');
      rethrow;
    }
  }

  /// Get order by ID
  Future<Order?> getOrderById(int orderId) async {
    try {
      return await getById(orderId);
    } catch (e) {
      print('Error getting order by ID: $e');
      rethrow;
    }
  }

  /// Get all orders (for admin purposes)
  Future<List<Order>> getAllOrders({Map<String, dynamic>? filter}) async {
    try {
      final response = await get(filter: filter);
      return response.items ?? [];
    } catch (e) {
      print('Error getting all orders: $e');
      rethrow;
    }
  }

  /// Create new order
  Future<Order> createOrder(OrderUpsertRequest request) async {
    try {
      return await insert(request.toJson());
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  /// Update order
  Future<Order> updateOrder(int orderId, OrderUpsertRequest request) async {
    try {
      return await update(orderId, request.toJson());
    } catch (e) {
      print('Error updating order: $e');
      rethrow;
    }
  }

  /// Delete order
  Future<bool> deleteOrder(int orderId) async {
    try {
      await delete(orderId);
      return true;
    } catch (e) {
      print('Error deleting order: $e');
      return false;
    }
  }
}
