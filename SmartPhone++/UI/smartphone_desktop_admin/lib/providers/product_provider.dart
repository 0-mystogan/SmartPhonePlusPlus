import 'package:smartphone_desktop_admin/model/product.dart';
import 'package:smartphone_desktop_admin/providers/base_provider.dart';

class ProductProvider extends BaseProvider<Product> {
  ProductProvider() : super("Product");

  @override
  Product fromJson(dynamic data) {
    return Product.fromJson(data);
  }
} 