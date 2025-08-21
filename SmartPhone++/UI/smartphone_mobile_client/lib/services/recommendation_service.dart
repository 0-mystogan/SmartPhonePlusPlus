import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smartphone_mobile_client/model/product.dart';
import 'package:smartphone_mobile_client/model/cart_item.dart';

class RecommendationService {
  static const String _baseUrl = 'http://10.0.2.2:5000/api'; // Android emulator localhost
  // static const String _baseUrl = 'http://localhost:5000/api'; // For web/desktop
  
  final http.Client _httpClient;
  
  RecommendationService({http.Client? httpClient}) 
      : _httpClient = httpClient ?? http.Client();

  /// Get product recommendations for a specific user based on their cart
  /// 
  /// This method gets recommendations directly from the backend by user ID,
  /// which fetches the user's cart from the database and provides intelligent recommendations.
  Future<List<Product>> getUserRecommendations(int userId) async {
    try {
      final uri = Uri.parse('$_baseUrl/ProductRecommendation/user/$userId?maxRecommendations=10');

      final response = await _httpClient.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final recommendations = jsonData
            .map((json) => Product.fromJson(json))
            .where((product) => product != null)
            .toList();

        return recommendations;
      } else {
        print('Failed to get user recommendations: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error getting user recommendations: $e');
      return [];
    }
  }

  /// Get product recommendations based on cart items (for backward compatibility)
  /// 
  /// This method implements association-based recommendations:
  /// 1. Name-based: Finds products with similar names (cases, glass, accessories)
  /// 2. Category-based: Finds complementary products from different categories
  /// 3. Featured: Falls back to featured products if needed
  Future<List<Product>> getRecommendations(List<CartItem> cartItems) async {
    try {
      if (cartItems.isEmpty) {
        return [];
      }

      // Extract data from cart items for recommendation
      final productIds = cartItems.map((item) => item.productId).toList();
      final productNames = cartItems.map((item) => item.productName).toList();
      final categoryIds = cartItems.map((item) => item.productCategoryId).where((id) => id != null).cast<int>().toList();

      // Build query parameters
      final queryParams = <String, String>{
        'cartItemProductIds': productIds.join(','),
        'cartItemProductNames': productNames.join(','),
        'cartItemCategoryIds': categoryIds.join(','),
        'maxRecommendations': '10',
      };

      // Build URL with query parameters
      final uri = Uri.parse('$_baseUrl/ProductRecommendation/cart-based')
          .replace(queryParameters: queryParams);

      // Make HTTP request
      final response = await _httpClient.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final recommendations = jsonData
            .map((json) => Product.fromJson(json))
            .where((product) => product != null)
            .toList();

        // Filter out products that are already in the cart
        final filteredRecommendations = recommendations
            .where((product) => !productIds.contains(product.id))
            .toList();

        return filteredRecommendations;
      } else {
        print('Failed to get recommendations: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error getting recommendations: $e');
      return [];
    }
  }

  /// Get recommendations for a specific product (for product detail pages)
  Future<List<Product>> getProductRecommendations(int productId, String productName, int categoryId) async {
    try {
      final queryParams = <String, String>{
        'cartItemProductIds': productId.toString(),
        'cartItemProductNames': productName,
        'cartItemCategoryIds': categoryId.toString(),
        'maxRecommendations': '6',
      };

      final uri = Uri.parse('$_baseUrl/ProductRecommendation/cart-based')
          .replace(queryParameters: queryParams);

      final response = await _httpClient.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((json) => Product.fromJson(json))
            .where((product) => product != null && product.id != productId)
            .toList();
      } else {
        print('Failed to get product recommendations: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting product recommendations: $e');
      return [];
    }
  }

  /// Dispose the HTTP client
  void dispose() {
    _httpClient.close();
  }
}
