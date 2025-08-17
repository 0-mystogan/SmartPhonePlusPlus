import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartphone_mobile_client/model/cart_item.dart';
import 'package:smartphone_mobile_client/providers/cart_manager_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize cart for demo user (you should get this from auth)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final cartManager = context.read<CartManagerProvider>();
        if (cartManager != null) {
          print('CartScreen: Initializing cart for user ID 1');
          cartManager.loadOrCreateCart(1); // Demo user ID
        }
      } catch (e) {
        print('CartScreen: CartManagerProvider not available: $e');
      }
    });
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
                        if (cartManager != null) {
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
                  onRefresh: () {
                    if (cartManager != null) {
                      return cartManager.loadOrCreateCart(1);
                    }
                    return Future.value();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartManager?.cartItems.length ?? 0,
                    itemBuilder: (context, index) {
                      if (cartManager != null && index < cartManager.cartItems.length) {
                        final cartItem = cartManager.cartItems[index];
                        return _buildCartItemCard(cartItem, cartManager);
                      }
                      return const SizedBox.shrink();
                    },
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Checkout'),
          content: const Text('Checkout functionality will be implemented in the next phase.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
