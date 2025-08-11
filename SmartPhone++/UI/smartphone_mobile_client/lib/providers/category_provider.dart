import 'package:smartphone_mobile_client/model/category.dart';
import 'package:smartphone_mobile_client/providers/base_provider.dart';

class CategoryProvider extends BaseProvider<Category> {
  CategoryProvider() : super("Category");

  @override
  Category fromJson(dynamic data) {
    return Category.fromJson(data);
  }
} 