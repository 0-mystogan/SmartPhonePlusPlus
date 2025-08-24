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
      print('CartManagerProvider: Starting loadOrCreateCart for user $userId');
      setLoading(true);
      clearError();
      
      // Ensure base URL is initialized
      await _cartProvider.initBaseUrl();
      print('CartManagerProvider: Base URL initialized');
      
      // Try to get existing cart using the user ID
      print('CartManagerProvider: Fetching cart from backend...');
      _currentCart = await _cartProvider.getMyCart(userId);
      
      if (_currentCart == null) {
        print('CartManagerProvider: No existing cart found for user $userId');
        // Cart will be created automatically when adding first item
        _cartItems = [];
      } else {
        print('CartManagerProvider: Found existing cart with ID: ${_currentCart!.id}');
        print('CartManagerProvider: Raw cart data: ${_currentCart!.toJson()}');
        print('CartManagerProvider: Cart has ${_currentCart!.cartItems?.length ?? 0} items');
        print('CartManagerProvider: Cart.cartItems is null: ${_currentCart!.cartItems == null}');
        
        // Load cart items from the cart response
        _cartItems = _currentCart!.cartItems ?? [];
        print('CartManagerProvider: Loaded ${_cartItems.length} cart items into local list');
        
        // Debug: Print cart items
        if (_cartItems.isNotEmpty) {
          for (int i = 0; i < _cartItems.length; i++) {
            final item = _cartItems[i];
            print('CartManagerProvider: Item $i: ${item.productName} (ID: ${item.id}, Qty: ${item.quantity})');
          }
        } else {
          print('CartManagerProvider: Cart items list is empty after loading');
        }
      }
      
      setLoading(false);
      notifyListeners();
      print('CartManagerProvider: loadOrCreateCart completed successfully');
    } catch (e) {
      print('CartManagerProvider: Error in loadOrCreateCart: $e');
      print('CartManagerProvider: Stack trace: ${StackTrace.current}');
      setError('Failed to load cart: $e');
      setLoading(false);
      notifyListeners();
    }
  }

  // Add product to cart using new unified endpoint
  Future<void> addToCart(Product product, {int quantity = 1}) async {
    try {
      setLoading(true);
      clearError();

      // Get current user ID from auth (you should implement this)
      await _getCurrentUserId();
      
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
      
      // If there's an error, refresh the cart to ensure sync
      if (e.toString().contains('400') || e.toString().contains('500')) {
        print('Cart might be out of sync, refreshing from backend');
        await _refreshCartFromBackend();
      }
      
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

      // Check if we have any cart items
      if (_cartItems.isEmpty) {
        print('No cart items found, refreshing cart state');
        await _refreshCartFromBackend();
        setLoading(false);
        setError('Cart is empty. Please add items to your cart.');
        return;
      }

      // Get the existing cart item first to preserve other properties
      final existingItemIndex = _cartItems.indexWhere((item) => item.id == cartItemId);
      if (existingItemIndex == -1) {
        print('Cart item with ID $cartItemId not found in local cache, refreshing cart');
        await _refreshCartFromBackend();
        setLoading(false);
        return;
      }
      
      final existingItem = _cartItems[existingItemIndex];
      await _getCurrentUserId();
      
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
      
      // If we get a "not found" error, the cart might be out of sync
      if (e.toString().contains('Product not found in cart') || 
          e.toString().contains('No active cart found') ||
          e.toString().contains('400')) {
        print('Cart appears to be out of sync, refreshing from backend');
        await _refreshCartFromBackend();
        setError('Cart was updated. Please try again.');
      } else {
        setError('Failed to update quantity: $e');
      }
      setLoading(false);
    }
  }

  // Remove item from cart using new unified endpoint
  Future<void> removeFromCart(int cartItemId) async {
    try {
      setLoading(true);
      clearError();

      // Check if we have any cart items
      if (_cartItems.isEmpty) {
        print('No cart items found, refreshing cart state');
        await _refreshCartFromBackend();
        setLoading(false);
        setError('Cart is empty. Nothing to remove.');
        return;
      }

      // Get the existing cart item first to get product ID
      final existingItemIndex = _cartItems.indexWhere((item) => item.id == cartItemId);
      if (existingItemIndex == -1) {
        print('Cart item with ID $cartItemId not found in local cache, refreshing cart');
        await _refreshCartFromBackend();
        setLoading(false);
        return;
      }
      
      final existingItem = _cartItems[existingItemIndex];
      await _getCurrentUserId();
      
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
      
      // If we get a "not found" error, the cart might be out of sync
      if (e.toString().contains('Product not found in cart') || 
          e.toString().contains('No active cart found') ||
          e.toString().contains('400')) {
        print('Cart appears to be out of sync, refreshing from backend');
        await _refreshCartFromBackend();
        setError('Cart was updated. Please try again.');
      } else {
        setError('Failed to remove item: $e');
      }
      setLoading(false);
    }
  }

  // Clear cart using new unified endpoint
  Future<void> clearCart() async {
    try {
      setLoading(true);
      clearError();

      // Get current user ID
      await _getCurrentUserId();
      
      try {
        // Clear cart using the existing clear endpoint
        await _cartProvider.clearCart();
        print('CartManagerProvider: Cart cleared successfully on backend');
      } catch (backendError) {
        print('CartManagerProvider: Backend cart clearing failed: $backendError');
        
        // If backend clearing fails, we still clear local data
        // This handles cases where the cart might already be empty on backend
        // or there's a temporary server issue
        if (backendError.toString().contains('500') || 
            backendError.toString().contains('Internal server error') ||
            backendError.toString().contains('No active cart found')) {
          print('CartManagerProvider: Server error or no active cart detected, clearing local cart data anyway');
        } else {
          // For other errors, re-throw to let caller handle
          rethrow;
        }
      }
      
      // Clear local data regardless of backend result
      _cartItems.clear();
      _currentCart = null;
      
      setLoading(false);
      notifyListeners();
      
      print('CartManagerProvider: Local cart data cleared successfully');
    } catch (e) {
      print('Error clearing cart: $e');
      setError('Failed to clear cart: $e');
      setLoading(false);
      rethrow; // Re-throw so caller can handle appropriately
    }
  }

  // Helper method to refresh cart from backend
  Future<void> _refreshCartFromBackend() async {
    try {
      final userId = await _getCurrentUserId();
      _currentCart = await _cartProvider.getMyCart(userId);
      
      if (_currentCart == null) {
        print('No cart found for user $userId after refresh');
        _cartItems = [];
      } else {
        print('Refreshed cart with ID: ${_currentCart!.id}');
        _cartItems = _currentCart!.cartItems ?? [];
      }
      
      notifyListeners();
    } catch (e) {
      print('Error refreshing cart from backend: $e');
      // Don't set error here as it's called from error handlers
    }
  }

  // Public method to force refresh cart state (useful after order creation)
  Future<void> forceRefreshCart() async {
    try {
      setLoading(true);
      clearError();
      
      final userId = await _getCurrentUserId();
      await loadOrCreateCart(userId);
      
      setLoading(false);
      print('CartManagerProvider: Cart force refreshed successfully');
    } catch (e) {
      print('CartManagerProvider: Error force refreshing cart: $e');
      setError('Failed to refresh cart: $e');
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
