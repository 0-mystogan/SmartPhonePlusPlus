import 'package:smartphone_desktop_admin/model/category.dart';
import 'package:smartphone_desktop_admin/providers/base_provider.dart';

class CategoryProvider extends BaseProvider<Category> {
  CategoryProvider() : super("Category");

  @override
  Category fromJson(dynamic data) {
    return Category.fromJson(data);
  }
} 