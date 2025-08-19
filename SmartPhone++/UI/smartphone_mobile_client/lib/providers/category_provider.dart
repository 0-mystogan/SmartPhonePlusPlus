import 'package:smartphone_mobile_client/model/category.dart';
import 'package:smartphone_mobile_client/model/search_result.dart';
import 'package:smartphone_mobile_client/providers/base_provider.dart';

class CategoryProvider extends BaseProvider<Category> {
  CategoryProvider() : super("Category");

  @override
  Category fromJson(dynamic data) {
    return Category.fromJson(data);
  }

  Future<List<Category>> getActiveCategories() async {
    try {
      final response = await getCustom('active');
      if (response != null) {
        List<Category> categories = [];
        
        // Handle different response formats
        if (response is List) {
          // Direct list of categories
          categories = response.map((item) => fromJson(item)).cast<Category>().toList();
        } else if (response is Map<String, dynamic>) {
          // Response with items and totalCount
          if (response['items'] != null) {
            categories = (response['items'] as List).map((item) => fromJson(item)).cast<Category>().toList();
          } else if (response['data'] != null) {
            // Alternative response format
            var data = response['data'];
            if (data is List) {
              categories = data.map((item) => fromJson(item)).cast<Category>().toList();
            }
          }
        }
        
        return categories;
      }
      return [];
    } catch (e) {
      print('Error getting active categories: $e');
      return [];
    }
  }
}
