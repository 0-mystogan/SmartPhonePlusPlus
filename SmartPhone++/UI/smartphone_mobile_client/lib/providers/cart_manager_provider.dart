import 'package:flutter/material.dart';
import 'package:smartphone_mobile_client/model/cart.dart';
import 'package:smartphone_mobile_client/model/cart_item.dart';
import 'package:smartphone_mobile_client/model/cart_upsert_request.dart';
import 'package:smartphone_mobile_client/model/cart_item_upsert_request.dart';
import 'package:smartphone_mobile_client/model/product.dart';
import 'package:smartphone_mobile_client/providers/cart_provider.dart';
import 'package:smartphone_mobile_client/providers/cart_item_provider.dart';

class CartManagerProvider with ChangeNotifier {
  final CartProvider _cartProvider = CartProvider();
  final CartItemProvider _cartItemProvider = CartItemProvider();
  
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
    await _cartItemProvider.initBaseUrl();
  }

  // Load or create cart for a user
  Future<void> loadOrCreateCart(int userId) async {
    try {
      setLoading(true);
      clearError();
      
      // Try to get existing cart
      _currentCart = await _cartProvider.getByUserId(userId);
      
      if (_currentCart == null) {
        // Create new cart if none exists
        final cartRequest = CartUpsertRequest(userId: userId);
        _currentCart = await _cartProvider.createCart(cartRequest);
        print('Created new cart with ID: ${_currentCart!.id}');
      } else {
        print('Found existing cart with ID: ${_currentCart!.id}');
      }
      
      // Load cart items
      if (_currentCart != null) {
        await _loadCartItems(_currentCart!.id);
        print('Loaded ${_cartItems.length} cart items');
      }
      
      setLoading(false);
    } catch (e) {
      print('Error in loadOrCreateCart: $e');
      setError('Failed to load cart: $e');
      setLoading(false);
    }
  }

  // Add product to cart
  Future<void> addToCart(Product product, {int quantity = 1}) async {
    try {
      if (_currentCart == null) {
        throw Exception('No active cart');
      }

      // Check if product already exists in cart
      final existingItem = _cartItems.firstWhere(
        (item) => item.productId == product.id,
        orElse: () => CartItem(
          id: 0,
          quantity: 0,
          createdAt: DateTime.now(),
          cartId: _currentCart!.id,
          productId: product.id,
          productName: product.name,
          productPrice: product.currentPrice ?? 0.0,
          totalPrice: 0.0,
        ),
      );

      if (existingItem.id == 0) {
        // New item - add to cart
        final request = CartItemUpsertRequest(
          quantity: quantity,
          productId: product.id,
          cartId: _currentCart!.id,
        );
        
        final newCartItem = await _cartItemProvider.addToCart(request);
        _cartItems.add(newCartItem);
      } else {
        // Existing item - update quantity
        final newQuantity = existingItem.quantity + quantity;
        await _cartItemProvider.updateQuantity(existingItem.id, newQuantity);
        
        // Update local item
        final index = _cartItems.indexWhere((item) => item.id == existingItem.id);
        if (index != -1) {
          _cartItems[index] = existingItem.copyWith(quantity: newQuantity);
        }
      }

      // Refresh cart data
      await _loadCartItems(_currentCart!.id);
      notifyListeners();
      
    } catch (e) {
      setError('Failed to add to cart: $e');
    }
  }

  // Update item quantity
  Future<void> updateItemQuantity(int cartItemId, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        await removeFromCart(cartItemId);
        return;
      }

      await _cartItemProvider.updateQuantity(cartItemId, newQuantity);
      
      // Update local item
      final index = _cartItems.indexWhere((item) => item.id == cartItemId);
      if (index != -1) {
        _cartItems[index] = _cartItems[index].copyWith(quantity: newQuantity);
      }
      
      notifyListeners();
    } catch (e) {
      setError('Failed to update quantity: $e');
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(int cartItemId) async {
    try {
      await _cartItemProvider.removeFromCart(cartItemId);
      _cartItems.removeWhere((item) => item.id == cartItemId);
      notifyListeners();
    } catch (e) {
      setError('Failed to remove item: $e');
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    try {
      for (final item in _cartItems) {
        await _cartItemProvider.removeFromCart(item.id);
      }
      _cartItems.clear();
      notifyListeners();
    } catch (e) {
      setError('Failed to clear cart: $e');
    }
  }

  // Load cart items
  Future<void> _loadCartItems(int cartId) async {
    try {
      print('Loading cart items for cart ID: $cartId');
      _cartItems = await _cartItemProvider.getByCartId(cartId);
      print('Successfully loaded ${_cartItems.length} cart items');
      

      
      // Update the cart's total items count
      if (_currentCart != null) {
        // Note: In a real app, you might want to update the cart's total in the database
        // For now, we'll just notify listeners to refresh the UI
        notifyListeners();
      }
    } catch (e) {
      print('Error loading cart items: $e');
      setError('Failed to load cart items: $e');
    }
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
