import 'package:smartphone_desktop_admin/model/product.dart';
import 'package:smartphone_desktop_admin/model/search_result.dart';
import 'package:smartphone_desktop_admin/providers/base_provider.dart';

class ProductProvider extends BaseProvider<Product> {
  ProductProvider() : super("Product");

  @override
  Product fromJson(dynamic data) {
    return Product.fromJson(data);
  }

  Future<SearchResult<Product>?> getByCategory(int categoryId, {Map<String, dynamic>? filter}) async {
    try {
      final response = await getCustom('category/$categoryId', queryParameters: filter);
      if (response != null) {
        List<Product> products = [];
        
        // Handle different response formats
        if (response is List) {
          // Direct list of products
          products = response.map((item) => fromJson(item)).cast<Product>().toList();
        } else if (response is Map<String, dynamic>) {
          // Response with items and totalCount
          if (response['items'] != null) {
            products = (response['items'] as List).map((item) => fromJson(item)).cast<Product>().toList();
          } else if (response['data'] != null) {
            // Alternative response format
            var data = response['data'];
            if (data is List) {
              products = data.map((item) => fromJson(item)).cast<Product>().toList();
            }
          }
        }
        
        return SearchResult<Product>(
          items: products,
          totalCount: products.length,
        );
      }
      return null;
    } catch (e) {
      print('Error getting products by category: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addImage(int productId, Map<String, dynamic> imageRequest) async {
    final response = await post('$productId/images', imageRequest);
    return response;
  }

  Future<void> deleteImage(int productId, int imageId) async {
    await deleteCustom('$productId/images/$imageId');
  }

  Future<Map<String, dynamic>> updateImage(int productId, int imageId, Map<String, dynamic> imageRequest) async {
    final response = await put('$productId/images/$imageId', imageRequest);
    return response;
  }
} 