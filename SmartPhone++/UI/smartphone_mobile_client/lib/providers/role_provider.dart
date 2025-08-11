import 'package:smartphone_mobile_client/model/role_response.dart';
import 'package:smartphone_mobile_client/providers/base_provider.dart';

class RoleProvider extends BaseProvider<RoleResponse> {
  RoleProvider() : super("Role");

  @override
  RoleResponse fromJson(dynamic json) {
    return RoleResponse.fromJson(json);
  }
}