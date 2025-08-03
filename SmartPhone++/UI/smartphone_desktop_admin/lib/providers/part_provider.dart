import 'package:smartphone_desktop_admin/model/part.dart';
import 'package:smartphone_desktop_admin/providers/base_provider.dart';

class PartProvider extends BaseProvider<Part> {
  PartProvider() : super("Part");

  @override
  Part fromJson(dynamic data) {
    return Part.fromJson(data);
  }
} 