import 'package:smartphone_mobile_client/model/service.dart';
import 'package:smartphone_mobile_client/providers/base_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ServiceProvider extends BaseProvider<Service> {
  ServiceProvider() : super("Service");

  @override
  Service fromJson(dynamic json) {
    return Service.fromJson(json);
  }

  Future<Service> complete(int id) async {
    var url = "${BaseProvider.baseUrl}${endpoint}/$id/complete";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.put(uri, headers: headers);
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return Service.fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }
}
