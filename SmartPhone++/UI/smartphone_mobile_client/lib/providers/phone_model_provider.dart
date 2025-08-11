import 'package:smartphone_mobile_client/model/phone_model.dart';
import 'package:smartphone_mobile_client/providers/base_provider.dart';

class PhoneModelProvider extends BaseProvider<PhoneModel> {
  PhoneModelProvider() : super("PhoneModel");

  @override
  PhoneModel fromJson(dynamic data) {
    return PhoneModel.fromJson(data);
  }
} 