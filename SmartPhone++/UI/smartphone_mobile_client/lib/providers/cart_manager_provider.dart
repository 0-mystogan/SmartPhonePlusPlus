import 'package:flutter/material.dart';
import 'package:smartphone_mobile_client/model/cart.dart';
import 'package:smartphone_mobile_client/model/cart_item.dart';
import 'package:smartphone_mobile_client/model/cart_item_operation_request.dart';
import 'package:smartphone_mobile_client/model/product.dart';
import 'package:smartphone_mobile_client/providers/cart_provider.dart';

class CartManagerProvider with ChangeNotifier {
  final CartProvider _cartProvider = CartProvider();
  
  Cart? _currentCart;
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  Cart? get currentCart => _currentCart;
  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get itemCount => _cartItems.length;
  double get totalAmount => _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  // Initialize base URL for providers
  Future<void> initBaseUrl() async {
    await _cartProvider.initBaseUrl();
  }

  // Load or create cart for a user
  Future<void> loadOrCreateCart(int userId) async {
    try {
      setLoading(true);
      clearError();
      
      // Try to get existing cart using the user ID
      _currentCart = await _cartProvider.getMyCart(userId);
      
      if (_currentCart == null) {
        print('No existing cart found for user $userId');
        // Cart will be created automatically when adding first item
        _cartItems = [];
      } else {
        print('Found existing cart with ID: ${_currentCart!.id}');
        // Load cart items from the cart response
        _cartItems = _currentCart!.cartItems ?? [];
      }
      
      setLoading(false);
    } catch (e) {
      print('Error in loadOrCreateCart: $e');
      setError('Failed to load cart: $e');
      setLoading(false);
    }
  }

  // Add product to cart using new unified endpoint
  Future<void> addToCart(Product product, {int quantity = 1}) async {
    try {
      setLoading(true);
      clearError();

      // Get current user ID from auth (you should implement this)
      final userId = await _getCurrentUserId();
      
      // Create request for the new unified endpoint
      final request = CartItemOperationRequest(
        productId: product.id,
        quantity: quantity,
      );
      
      // Add item to cart using the new /cart/add endpoint
      final updatedCart = await _cartProvider.addItemToCart(request);
      
      // Update local cart data
      _currentCart = updatedCart;
      _cartItems = updatedCart.cartItems ?? [];
      
      setLoading(false);
      notifyListeners();
      
    } catch (e) {
      print('Error adding to cart: $e');
      setError('Failed to add to cart: $e');
      setLoading(false);
    }
  }

  // Update item quantity using new unified endpoint
  Future<void> updateItemQuantity(int cartItemId, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        await removeFromCart(cartItemId);
        return;
      }

      setLoading(true);
      clearError();

      // Get the existing cart item first to preserve other properties
      final existingItem = _cartItems.firstWhere((item) => item.id == cartItemId);
      final userId = await _getCurrentUserId();
      
      final request = CartItemOperationRequest(
        productId: existingItem.productId,
        quantity: newQuantity,
      );
      
      // Update item using the new /cart/update endpoint
      final updatedCart = await _cartProvider.updateItemQuantity(request);
      
      // Update local cart data
      _currentCart = updatedCart;
      _cartItems = updatedCart.cartItems ?? [];
      
      setLoading(false);
      notifyListeners();
    } catch (e) {
      print('Error updating quantity: $e');
      setError('Failed to update quantity: $e');
      setLoading(false);
    }
  }

  // Remove item from cart using new unified endpoint
  Future<void> removeFromCart(int cartItemId) async {
    try {
      setLoading(true);
      clearError();

      // Get the existing cart item first to get product ID
      final existingItem = _cartItems.firstWhere((item) => item.id == cartItemId);
      final userId = await _getCurrentUserId();
      
      final request = CartItemOperationRequest(
        productId: existingItem.productId,
        quantity: 0, // Quantity doesn't matter for removal
      );
      
      // Remove item using the new /cart/remove endpoint
      final updatedCart = await _cartProvider.removeItemFromCart(request);
      
      // Update local cart data
      _currentCart = updatedCart;
      _cartItems = updatedCart.cartItems ?? [];
      
      setLoading(false);
      notifyListeners();
    } catch (e) {
      print('Error removing item: $e');
      setError('Failed to remove item: $e');
      setLoading(false);
    }
  }

  // Clear cart using new unified endpoint
  Future<void> clearCart() async {
    try {
      setLoading(true);
      clearError();

      // Get current user ID
      final userId = await _getCurrentUserId();
      
      // Clear cart using the existing clear endpoint
      await _cartProvider.clearCart();
      
      // Clear local data
      _cartItems.clear();
      _currentCart = null;
      
      setLoading(false);
      notifyListeners();
    } catch (e) {
      print('Error clearing cart: $e');
      setError('Failed to clear cart: $e');
      setLoading(false);
    }
  }

  // Helper method to get current user ID
  Future<int> _getCurrentUserId() async {
    // TODO: Implement proper user authentication
    // For now, return a demo user ID
    return 1;
  }

  // Helper methods
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
