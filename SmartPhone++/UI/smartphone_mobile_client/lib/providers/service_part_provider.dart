import 'package:smartphone_mobile_client/model/search_result.dart';
import 'package:smartphone_mobile_client/providers/base_provider.dart';
import 'package:smartphone_mobile_client/model/service_part.dart';
import 'package:smartphone_mobile_client/providers/part_provider.dart';

class ServicePartProvider extends BaseProvider<ServicePart> {
  ServicePartProvider() : super("ServicePart");

  @override
  ServicePart fromJson(dynamic data) {
    return ServicePart.fromJson(data);
  }

  Future<SearchResult<ServicePart>> getForService(int serviceId) async {
    final data = await getCustom("service/$serviceId");
    final List<ServicePart> items = data is List
        ? List<ServicePart>.from(data.map((e) => fromJson(e)))
        : <ServicePart>[];
    return SearchResult<ServicePart>(items: items, totalCount: items.length);
  }

  Future<bool> addPartToService({
    required int serviceId,
    required int partId,
    required int quantity,
    required double unitPrice,
    double? discountAmount,
  }) async {
    final payload = {
      "quantity": quantity,
      "unitPrice": unitPrice,
      "discountAmount": discountAmount,
    };
    final result = await postCustom("service/$serviceId/part/$partId", payload);
    final success = result == true || (result is Map && (result["success"] == true));
    // If the server succeeded, optimistically reduce stock on the client via PartController API
    if (success) {
      try {
        final partProvider = PartProvider();
        final current = await partProvider.getById(partId);
        if (current != null) {
          final newQty = (current.stockQuantity - quantity) < 0
              ? 0
              : current.stockQuantity - quantity;
          await partProvider.updateStockQuantity(partId, newQty);
        }
      } catch (_) {}
    }
    return success;
  }

  Future<bool> removePartFromService({
    required int serviceId,
    required int partId,
  }) async {
    await deleteCustom("service/$serviceId/part/$partId");
    return true;
  }

  Future<bool> updateQuantity({
    required int serviceId,
    required int partId,
    required int quantity,
  }) async {
    final result = await putCustom("service/$serviceId/part/$partId/quantity", quantity);
    return result == true || (result is Map && (result["success"] == true));
  }
}


