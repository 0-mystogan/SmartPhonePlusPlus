import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartphone_mobile_client/model/cart_item.dart';
import 'package:smartphone_mobile_client/model/product.dart';
import 'package:smartphone_mobile_client/providers/cart_manager_provider.dart';
import 'package:smartphone_mobile_client/providers/auth_provider.dart';
import 'package:smartphone_mobile_client/providers/product_provider.dart';
import 'package:smartphone_mobile_client/providers/recommendation_provider.dart';
import 'package:smartphone_mobile_client/screens/stripe_payment_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _hasLoadedRecommendations = false; // Track if recommendations have been loaded
  bool _mounted = true; // Track if widget is still mounted

  @override
  void initState() {
    super.initState();
    // Initialize cart for current user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final cartManager = context.read<CartManagerProvider>();
        final authProvider = context.read<AuthProvider>();
        
        if (cartManager != null && authProvider.currentUser != null) {
          print('CartScreen: Initializing cart for user ID ${authProvider.currentUser!.id}');
          cartManager.loadOrCreateCart(authProvider.currentUser!.id);
        } else {
          // For demo purposes, use user ID 1 if no auth user
          print('CartScreen: No auth user, using demo user ID 1');
          cartManager.loadOrCreateCart(1);
        }
      } catch (e) {
        print('CartScreen: CartManagerProvider not available: $e');
      }
    });
  }

  @override
  void dispose() {
    _mounted = false; // Mark widget as disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<CartManagerProvider>(
            builder: (context, cartManager, child) {
              if (cartManager != null && cartManager.cartItems.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: () => _showClearCartDialog(context),
                  tooltip: 'Clear Cart',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<CartManagerProvider>(
        builder: (context, cartManager, child) {
          // Check if cartManager is properly initialized
          if (cartManager == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cart service not available',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (cartManager.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.purple,
              ),
            );
          }

          if (cartManager.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    cartManager.error!,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final authProvider = context.read<AuthProvider>();
                      if (cartManager != null && authProvider.currentUser != null) {
                        cartManager.loadOrCreateCart(authProvider.currentUser!.id);
                      } else {
                        // For demo purposes, use user ID 1 if no auth user
                        cartManager.loadOrCreateCart(1);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (cartManager == null || cartManager.cartItems.isEmpty) {
            print('CartScreen: Cart is empty or null. Cart: ${cartManager?.currentCart?.id}, Items: ${cartManager?.cartItems.length}');
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add some products to get started!',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    final authProvider = context.read<AuthProvider>();
                    if (cartManager != null && authProvider.currentUser != null) {
                      return cartManager.loadOrCreateCart(authProvider.currentUser!.id);
                    } else {
                      // For demo purposes, use user ID 1 if no auth user
                      return cartManager.loadOrCreateCart(1);
                    }
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Cart items
                      ...cartManager.cartItems.map((cartItem) => 
                        _buildCartItemCard(cartItem, cartManager)
                      ),
                      
                      // Recommendations section
                      if (cartManager.cartItems.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildRecommendationsSection(cartManager.cartItems),
                      ],
                    ],
                  ),
                ),
              ),
              _buildCartSummary(cartManager),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItemCard(CartItem cartItem, CartManagerProvider? cartManager) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Product image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[100],
              ),
              child: cartItem.productImageUrl != null && cartItem.productImageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        base64Decode(cartItem.productImageUrl!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading cart item image: $error');
                          return const Icon(
                            Icons.image_not_supported_outlined,
                            size: 32,
                            color: Colors.grey,
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.image_not_supported_outlined,
                      size: 32,
                      color: Colors.grey,
                    ),
            ),
            const SizedBox(width: 16),
            
            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${cartItem.productPrice?.toStringAsFixed(2) ?? '0.00'} BAM',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Quantity controls
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (cartItem.quantity > 1 && cartManager != null) {
                            cartManager.updateItemQuantity(
                              cartItem.id,
                              cartItem.quantity - 1,
                            );
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                        color: Colors.purple,
                        iconSize: 20,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${cartItem.quantity}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (cartManager != null) {
                            cartManager.updateItemQuantity(
                              cartItem.id,
                              cartItem.quantity + 1,
                            );
                          }
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        color: Colors.purple,
                        iconSize: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Total price and remove button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${cartItem.totalPrice.toStringAsFixed(2)} BAM',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 8),
                IconButton(
                  onPressed: () => _showRemoveItemDialog(context, cartItem, cartManager),
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  iconSize: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary(CartManagerProvider? cartManager) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Items:',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '${cartManager?.itemCount ?? 0}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(cartManager?.totalAmount ?? 0.0).toStringAsFixed(2)} BAM',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (cartManager != null && cartManager.cartItems.isNotEmpty)
                  ? () => _showCheckoutDialog(context)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveItemDialog(BuildContext context, CartItem cartItem, CartManagerProvider? cartManager) {
    if (cartManager == null) return;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Item'),
          content: Text('Are you sure you want to remove "${cartItem.productName}" from your cart?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                cartManager.removeFromCart(cartItem.id);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Remove',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Cart'),
          content: const Text('Are you sure you want to remove all items from your cart?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<CartManagerProvider>().clearCart();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Clear All',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCheckoutDialog(BuildContext context) {
    final cartManager = context.read<CartManagerProvider>();
    if (cartManager != null && cartManager.cartItems.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StripePaymentScreen(
            cartItems: cartManager.cartItems,
            totalAmount: cartManager.totalAmount,
          ),
        ),
      );
    }
  }

  Widget _buildRecommendationsSection(List<CartItem> cartItems) {
    // Only show recommendations if we have cart items with category information
    final hasCategoryInfo = cartItems.any((item) => item.productCategoryId != null);
    
    if (!hasCategoryInfo) {
      return const SizedBox.shrink();
    }

    // Load recommendations only once when this section is built, but only if widget is mounted
    if (_mounted && !_hasLoadedRecommendations) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_mounted && !_hasLoadedRecommendations) { // Double-check mounted state
          _loadRecommendations(cartItems);
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: Colors.orange[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'You might also like',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Consumer<RecommendationProvider>(
          builder: (context, recommendationProvider, child) {
            if (recommendationProvider.isLoading)
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(
                    color: Colors.purple,
                    strokeWidth: 2,
                  ),
                ),
              );
            else if (recommendationProvider.recommendations.isEmpty)
              return Container(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No recommendations available',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            else
              return SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recommendationProvider.recommendations.length,
                  itemBuilder: (context, index) {
                    final product = recommendationProvider.recommendations[index];
                    return _buildRecommendationCard(product, cartItems);
                  },
                ),
              );
          },
        )
      ],
    );
  }

  Widget _buildRecommendationCard(Product product, List<CartItem> cartItems) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  color: Colors.grey[100],
                ),
                child: product.productImages != null && product.productImages!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.memory(
                          base64Decode(product.productImages!.first.imageData!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image_not_supported_outlined,
                              size: 32,
                              color: Colors.grey,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.image_not_supported_outlined,
                        size: 32,
                        color: Colors.grey,
                      ),
              ),
            ),
            
            // Product details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.currentPrice?.toStringAsFixed(2) ?? '0.00'} BAM',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _addToCart(product),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadRecommendations(List<CartItem> cartItems) async {
    if (!_mounted) return;

    try {
      print('CartScreen: Starting to load recommendations');
      
      // Get recommendation provider from context
      final recommendationProvider = context.read<RecommendationProvider>();
      print('CartScreen: Got recommendation provider: ${recommendationProvider.runtimeType}');

      // Get current user ID from auth provider
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.currentUser?.id ?? 1; // Fallback to user 1 for demo
      print('CartScreen: Using user ID: $userId');

      // Use the new user-based recommendation method that fetches cart from database
      print('CartScreen: Calling getUserRecommendations...');
      final recommendations = await recommendationProvider.getUserRecommendations(userId);
      print('CartScreen: Received ${recommendations.length} recommendations');
      
      // Mark recommendations as loaded
      if (_mounted) {
        setState(() {
          _hasLoadedRecommendations = true;
        });
      }
    } catch (e) {
      print('CartScreen: Error loading recommendations: $e');
      print('CartScreen: Error stack trace: ${StackTrace.current}');
    }
  }

  void _addToCart(Product product) {
    try {
      final cartManager = context.read<CartManagerProvider>();
      
      if (cartManager != null) {
        // Add product to cart using the Product object
        cartManager.addToCart(product);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} added to cart'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Reset recommendations flag and reload to exclude the added product
        if (_mounted) {
          _hasLoadedRecommendations = false;
          _loadRecommendations(cartManager.cartItems);
        }
      }
    } catch (e) {
      print('Error adding product to cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error adding product to cart'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
