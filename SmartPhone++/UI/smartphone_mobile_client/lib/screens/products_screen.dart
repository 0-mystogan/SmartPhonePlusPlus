import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smartphone_mobile_client/model/product.dart';
import 'package:smartphone_mobile_client/providers/product_provider.dart';
import 'package:smartphone_mobile_client/providers/cart_manager_provider.dart';
import 'package:smartphone_mobile_client/widgets/cart_fab.dart';
import 'package:smartphone_mobile_client/widgets/cart_icon.dart';
import 'package:smartphone_mobile_client/screens/cart_screen.dart';
import 'package:provider/provider.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      
      // Initialize the base URL first
      await productProvider.initBaseUrl();
      
      // Get all products and filter for featured ones
      final allProducts = await productProvider.get();
      
      setState(() {
        _products = allProducts.items ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _addToCart(Product product) async {
    try {
      final cartManager = Provider.of<CartManagerProvider>(context, listen: false);
      
      // Initialize base URL if not already done
      await cartManager.initBaseUrl();
      
      // Load or create cart for demo user (you should get this from auth)
      await cartManager.loadOrCreateCart(1);
      
      // Add product to cart
      await cartManager.addToCart(product);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} added to cart!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
                      action: SnackBarAction(
              label: 'View Cart',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CartScreen(),
                  ),
                );
              },
            ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add to cart: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Webshop'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: const [
          CartIcon(),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: const CartFAB(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.purple,
        ),
      );
    }

    if (_error != null) {
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
              _error!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
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

    if (_products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No products available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Determine grid layout based on screen width
          int crossAxisCount = 2; // Default for small screens
          double childAspectRatio = 0.8; // Increased aspect ratio to make cards more compact
          
          if (constraints.maxWidth > 600) {
            // Medium screens (tablets)
            crossAxisCount = 3;
            childAspectRatio = 0.85;
          }
          if (constraints.maxWidth > 900) {
            // Large screens (large tablets)
            crossAxisCount = 4;
            childAspectRatio = 0.9;
          }
          if (constraints.maxWidth > 1200) {
            // Extra large screens
            crossAxisCount = 5;
            childAspectRatio = 0.95;
          }

          return GridView.builder(
            padding: EdgeInsets.all(constraints.maxWidth > 600 ? 24 : 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: constraints.maxWidth > 600 ? 20 : 16,
              mainAxisSpacing: constraints.maxWidth > 600 ? 20 : 16,
            ),
            itemCount: _products.length,
            itemBuilder: (context, index) {
              final product = _products[index];
              return _buildProductCard(product, constraints);
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Product product, BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth <= 600;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
      ),
      child: Stack(
        children: [
          // Main product card content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image container - fixed height to prevent overflow
              Container(
                height: 100, // Reduced height from 120 to 100 for more compact cards
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(isSmallScreen ? 12 : 16),
                  ),
                  color: Colors.grey[100],
                ),
                child: Stack(
                  children: [
                    // Product image
                    product.productImages != null && product.productImages!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(isSmallScreen ? 12 : 16),
                            ),
                            child: product.productImages!.first.imageData != null
                                ? Image.memory(
                                    base64Decode(product.productImages!.first.imageData!),
                                    fit: BoxFit.contain,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(
                                          Icons.image_not_supported_outlined,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                  ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                    
                    // Cart icon overlay on top right
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => _addToCart(product),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.shopping_cart,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Product information container - flexible height
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product name
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      
                      // Brand
                      if (product.brand != null && product.brand!.isNotEmpty)
                        Text(
                          product.brand!,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Hanging price tag on the right side
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '${product.currentPrice?.toStringAsFixed(2) ?? '0.00'} BAM',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
