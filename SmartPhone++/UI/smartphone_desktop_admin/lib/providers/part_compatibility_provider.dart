import 'package:smartphone_desktop_admin/model/part_compatibility.dart';
import 'package:smartphone_desktop_admin/model/search_result.dart';
import 'package:smartphone_desktop_admin/providers/base_provider.dart';

class PartCompatibilityProvider extends BaseProvider<PartCompatibility> {
  PartCompatibilityProvider() : super("PartCompatibility");

  @override
  PartCompatibility fromJson(dynamic data) {
    return PartCompatibility.fromJson(data);
  }

  Future<SearchResult<PartCompatibility>> getByPhoneModel(int phoneModelId) async {
    final data = await getCustom("phone/$phoneModelId");
    final List<PartCompatibility> items = data is List
        ? List<PartCompatibility>.from(data.map((e) => fromJson(e)))
        : <PartCompatibility>[];
    return SearchResult<PartCompatibility>(items: items, totalCount: items.length);
  }

  Future<SearchResult<PartCompatibility>> getByPart(int partId) async {
    final data = await getCustom("part/$partId");
    final List<PartCompatibility> items = data is List
        ? List<PartCompatibility>.from(data.map((e) => fromJson(e)))
        : <PartCompatibility>[];
    return SearchResult<PartCompatibility>(items: items, totalCount: items.length);
  }
} 