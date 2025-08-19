import 'package:smartphone_mobile_client/model/product.dart';
import 'package:smartphone_mobile_client/model/cart_item.dart';
import 'package:smartphone_mobile_client/providers/product_provider.dart';

class RecommendationService {
  final ProductProvider _productProvider;

  RecommendationService(this._productProvider);

  /// Get recommended products based on cart items
  /// This service suggests products from related categories
  Future<List<Product>> getRecommendations(List<CartItem> cartItems) async {
    if (cartItems.isEmpty) {
      return await _getFeaturedProducts();
    }

    try {
      // Extract unique category IDs from cart items
      final Set<int> cartCategoryIds = cartItems
          .where((item) => item.productCategoryId != null)
          .map((item) => item.productCategoryId!)
          .toSet();

      if (cartCategoryIds.isEmpty) {
        return await _getFeaturedProducts();
      }

      // Get recommended products from cart categories (excluding products already in cart)
      final List<Product> recommendations = [];
      final Set<int> recommendedProductIds = <int>{};
      final Set<int> cartProductIds = cartItems.map((item) => item.productId).toSet();

      // Add products from cart categories
      for (int categoryId in cartCategoryIds) {
        try {
          final categoryProducts = await _productProvider.getByCategory(categoryId);
          if (categoryProducts?.items != null) {
            for (Product product in categoryProducts!.items!) {
              // Skip if product is already in cart or already recommended
              if (!cartProductIds.contains(product.id) && 
                  !recommendedProductIds.contains(product.id)) {
                recommendations.add(product);
                recommendedProductIds.add(product.id);
                
                // Limit recommendations per category
                if (recommendations.length >= 6) break;
              }
            }
          }
        } catch (e) {
          print('Error getting products for category $categoryId: $e');
          continue;
        }
        
        // Limit total recommendations
        if (recommendations.length >= 8) break;
      }

      // If we don't have enough recommendations, add some featured products
      if (recommendations.length < 4) {
        final featuredProducts = await _getFeaturedProducts();
        for (Product product in featuredProducts) {
          if (!cartProductIds.contains(product.id) && 
              !recommendedProductIds.contains(product.id)) {
            recommendations.add(product);
            recommendedProductIds.add(product.id);
            
            if (recommendations.length >= 8) break;
          }
        }
      }

      // Shuffle recommendations for variety
      recommendations.shuffle();
      
      // Return top 8 recommendations
      return recommendations.take(8).toList();
    } catch (e) {
      print('Error getting recommendations: $e');
      return await _getFeaturedProducts();
    }
  }

  /// Get featured products as fallback
  Future<List<Product>> _getFeaturedProducts() async {
    try {
      final featuredProducts = await _productProvider.getCustom('featured');
      if (featuredProducts != null && featuredProducts is List) {
        final List<Product> products = [];
        for (var productData in featuredProducts) {
          try {
            final product = _productProvider.fromJson(productData);
            products.add(product);
            if (products.length >= 6) break;
          } catch (e) {
            print('Error parsing featured product: $e');
            continue;
          }
        }
        return products;
      }
    } catch (e) {
      print('Error fetching featured products: $e');
    }
    return [];
  }

  /// Check if a product is already in the cart
  bool _isProductInCart(int productId, List<CartItem> cartItems) {
    return cartItems.any((item) => item.productId == productId);
  }
}
