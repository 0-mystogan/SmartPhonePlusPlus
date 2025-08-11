import 'package:smartphone_mobile_client/model/user.dart';
import 'package:smartphone_mobile_client/providers/base_provider.dart';

class UserProvider extends BaseProvider<User> {
  UserProvider() : super("Users");

  @override
  User fromJson(dynamic json) {
    return User.fromJson(json);
  }
}
