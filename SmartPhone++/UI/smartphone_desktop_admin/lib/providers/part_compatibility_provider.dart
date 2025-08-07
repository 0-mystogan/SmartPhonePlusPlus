import 'package:smartphone_desktop_admin/model/part_compatibility.dart';
import 'package:smartphone_desktop_admin/providers/base_provider.dart';

class PartCompatibilityProvider extends BaseProvider<PartCompatibility> {
  PartCompatibilityProvider() : super("PartCompatibility");

  @override
  PartCompatibility fromJson(dynamic data) {
    return PartCompatibility.fromJson(data);
  }
} 