import 'package:smartphone_desktop_admin/model/product.dart';
import 'package:smartphone_desktop_admin/providers/base_provider.dart';

class ProductProvider extends BaseProvider<Product> {
  ProductProvider() : super("Product");

  @override
  Product fromJson(dynamic data) {
    return Product.fromJson(data);
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