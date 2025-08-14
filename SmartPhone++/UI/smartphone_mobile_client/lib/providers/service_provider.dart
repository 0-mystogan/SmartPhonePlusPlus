import 'package:smartphone_mobile_client/model/service.dart';
import 'package:smartphone_mobile_client/providers/base_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ServiceProvider extends BaseProvider<Service> {
  ServiceProvider() : super("Service");

  @override
  Service fromJson(dynamic data) {
    return Service.fromJson(data);
  }

  Future<Service?> getByServiceNumber(String serviceNumber) async {
    try {
      // Get all services and find the one with matching description (service number)
      final allServices = await get();
      if (allServices.items != null) {
        for (var service in allServices.items!) {
          if (service.description == serviceNumber) {
            return service;
          }
        }
      }
      return null;
    } catch (e) {
      print('Error getting service by service number: $e');
      rethrow;
    }
  }
}
