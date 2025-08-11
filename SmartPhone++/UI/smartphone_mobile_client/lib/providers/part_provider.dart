import 'package:smartphone_mobile_client/model/part.dart';
import 'package:smartphone_mobile_client/providers/base_provider.dart';

class PartProvider extends BaseProvider<Part> {
  PartProvider() : super("Part");

  @override
  Part fromJson(dynamic data) {
    return Part.fromJson(data);
  }

  Future<bool> updateStockQuantity(int id, int newQuantity) async {
    final result = await putCustom("$id/stock", newQuantity);
    return result == true || (result is Map && (result["success"] == true));
  }

  Future<bool> checkAvailability(int id, int requiredQuantity) async {
    final result = await getCustom("$id/availability", queryParameters: {"requiredQuantity": requiredQuantity});
    return result == true || (result is Map && (result["result"] == true));
  }
} 