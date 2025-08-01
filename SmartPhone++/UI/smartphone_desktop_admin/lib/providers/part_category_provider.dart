import 'package:smartphone_desktop_admin/model/part_category.dart';
import 'package:smartphone_desktop_admin/providers/base_provider.dart';

class PartCategoryProvider extends BaseProvider<PartCategory> {
  PartCategoryProvider() : super("PartCategory");

  @override
  PartCategory fromJson(dynamic data) {
    return PartCategory.fromJson(data);
  }
} 