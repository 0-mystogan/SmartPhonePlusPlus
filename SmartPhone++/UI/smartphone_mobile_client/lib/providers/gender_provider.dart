import 'package:smartphone_mobile_client/model/gender.dart';
import 'package:smartphone_mobile_client/providers/base_provider.dart';

class GenderProvider extends BaseProvider<Gender> {
  GenderProvider() : super("Gender");

  @override
  Gender fromJson(dynamic json) {
    return Gender.fromJson(json);
  }
}
