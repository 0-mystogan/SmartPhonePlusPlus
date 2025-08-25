import 'package:flutter/foundation.dart';
import 'package:smartphone_mobile_client/model/product.dart';
import 'package:smartphone_mobile_client/model/cart_item.dart';
import 'package:smartphone_mobile_client/providers/base_provider.dart';

class RecommendationProvider extends BaseProvider<Product> {
  List<Product> _recommendations = [];
  bool _isLoading = false;
  String? _error;

  // Fix: Include the correct API endpoint path
  RecommendationProvider() : super("api/ProductRecommendation");

  // Getters
  List<Product> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get product recommendations for a specific user based on their cart
  ///
  /// This method gets recommendations directly from the backend by user ID,
  /// which fetches the user's cart from the database and provides intelligent recommendations.
  Future<List<Product>> getUserRecommendations(
    int userId, {
    int maxRecommendations = 3,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Initialize base URL if not already done
      await initBaseUrl();

      print('RecommendationProvider: Getting recommendations for user $userId');
      print('RecommendationProvider: Base URL: ${BaseProvider.baseUrl}');
      print('RecommendationProvider: Endpoint: $endpoint');

      // Construct the full URL for debugging
      final fullUrl =
          '${BaseProvider.baseUrl}$endpoint/user/$userId?maxRecommendations=$maxRecommendations';
      print('RecommendationProvider: Full URL: $fullUrl');

      final response = await getCustom(
        'user/$userId',
        queryParameters: {'maxRecommendations': maxRecommendations.toString()},
      );

      print('RecommendationProvider: Response received: $response');
      print('RecommendationProvider: Response type: ${response.runtimeType}');

      if (response != null && response is List) {
        final recommendations = response
            .map((json) => fromJson(json))
            .where((product) => product != null)
            .cast<Product>()
            .toList();

        print(
          'RecommendationProvider: Parsed ${recommendations.length} recommendations',
        );

        _recommendations = recommendations;
        _isLoading = false;
        notifyListeners();
        return recommendations;
      } else {
        _error = 'Invalid response format: $response';
        _isLoading = false;
        notifyListeners();
        print('RecommendationProvider: Invalid response format: $response');
        return [];
      }
    } catch (e) {
      _error = 'Error getting user recommendations: $e';
      _isLoading = false;
      notifyListeners();
      print('RecommendationProvider: Error getting user recommendations: $e');
      print('RecommendationProvider: Error stack trace: ${StackTrace.current}');
      return [];
    }
  }

  /// Get product recommendations based on cart items (for backward compatibility)
  ///
  /// This method implements association-based recommendations:
  /// 1. Name-based: Finds products with similar names (cases, glass, accessories)
  /// 2. Category-based: Finds complementary products from different categories
  /// 3. Featured: Falls back to featured products if needed
  Future<List<Product>> getCartBasedRecommendations(
    List<CartItem> cartItems, {
    int maxRecommendations = 3,
  }) async {
    try {
      if (cartItems.isEmpty) {
        _recommendations = [];
        notifyListeners();
        return [];
      }

      _isLoading = true;
      _error = null;
      notifyListeners();

      // Initialize base URL if not already done
      await initBaseUrl();

      // Extract data from cart items for recommendation
      final productIds = cartItems.map((item) => item.productId).toList();
      final productNames = cartItems.map((item) => item.productName).toList();
      final categoryIds = cartItems
          .map((item) => item.productCategoryId)
          .where((id) => id != null)
          .cast<int>()
          .toList();

      // Build query parameters
      final queryParams = <String, String>{
        'cartItemProductIds': productIds.join(','),
        'cartItemProductNames': productNames.join(','),
        'cartItemCategoryIds': categoryIds.join(','),
        'maxRecommendations': maxRecommendations.toString(),
      };

      final response = await getCustom(
        'cart-based',
        queryParameters: queryParams,
      );

      if (response != null && response is List) {
        final recommendations = response
            .map((json) => fromJson(json))
            .where((product) => product != null)
            .cast<Product>()
            .toList();

        // Filter out products that are already in the cart
        final filteredRecommendations = recommendations
            .where((product) => !productIds.contains(product.id))
            .toList();

        _recommendations = filteredRecommendations;
        _isLoading = false;
        notifyListeners();
        return filteredRecommendations;
      } else {
        _error = 'Invalid response format';
        _isLoading = false;
        notifyListeners();
        return [];
      }
    } catch (e) {
      _error = 'Error getting cart-based recommendations: $e';
      _isLoading = false;
      notifyListeners();
      print('Error getting cart-based recommendations: $e');
      return [];
    }
  }

  /// Get recommendations for a specific product (for product detail pages)
  Future<List<Product>> getProductRecommendations(
    int productId,
    String productName,
    int categoryId, {
    int maxRecommendations = 3,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Initialize base URL if not already done
      await initBaseUrl();

      final queryParams = <String, String>{
        'cartItemProductIds': productId.toString(),
        'cartItemProductNames': productName,
        'cartItemCategoryIds': categoryId.toString(),
        'maxRecommendations': maxRecommendations.toString(),
      };

      final response = await getCustom(
        'cart-based',
        queryParameters: queryParams,
      );

      if (response != null && response is List) {
        final recommendations = response
            .map((json) => fromJson(json))
            .where((product) => product != null && product.id != productId)
            .cast<Product>()
            .toList();

        _recommendations = recommendations;
        _isLoading = false;
        notifyListeners();
        return recommendations;
      } else {
        _error = 'Invalid response format';
        _isLoading = false;
        notifyListeners();
        return [];
      }
    } catch (e) {
      _error = 'Error getting product recommendations: $e';
      _isLoading = false;
      notifyListeners();
      print('Error getting product recommendations: $e');
      return [];
    }
  }

  /// Clear recommendations and error
  void clearRecommendations() {
    _recommendations = [];
    _error = null;
    notifyListeners();
  }

  /// Clear error only
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  Product fromJson(dynamic data) {
    return Product.fromJson(data);
  }
}
