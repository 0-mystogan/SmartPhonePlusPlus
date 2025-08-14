import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:smartphone_mobile_client/providers/auth_provider.dart';
import 'package:smartphone_mobile_client/model/search_result.dart';
import 'package:network_info_plus/network_info_plus.dart';

abstract class BaseProvider<T> with ChangeNotifier {
  static String? baseUrl;
  @protected
  String endpoint = "";

  BaseProvider(String endpoint) {
    this.endpoint = endpoint;
  }

  /// Call this before making requests
  Future<void> initBaseUrl() async {
    const baseFromEnv = String.fromEnvironment("baseUrl");

    if (baseFromEnv.isNotEmpty) {
      baseUrl = baseFromEnv;
      return;
    }

    if (Platform.isAndroid) {
      // Android emulator
      baseUrl = "http://10.0.2.2:7074/";
      
    } else if (Platform.isIOS) {
      // iOS simulator
      baseUrl = "http://localhost:7074/";
    } else {
      // Physical device or other
      final info = NetworkInfo();
      String? ip = await info.getWifiGatewayIP(); // Router's IP
      if (ip == null) {
        ip = await info.getWifiIP(); // Device's IP
      }
      if (ip != null) {
        baseUrl = "http://$ip:7074/";
      } else {
        throw Exception("Unable to determine local IP address");
      }
    }
  }

  Future<SearchResult<T>> get({dynamic filter}) async {
    var url = "$baseUrl$endpoint";

    if (filter != null) {
      var queryString = getQueryString(filter);
      url = "$url?$queryString";
    }

    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 10));

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);

      var result = SearchResult<T>();
      result.totalCount = data['totalCount'];
      result.items = data["items"] != null
          ? List<T>.from(data["items"].map((e) => fromJson(e)))
          : <T>[];

      return result;
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<T?> getById(int id) async {
    var url = "$baseUrl$endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 10));

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      if (data == null) return null;
      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<T> insert(dynamic request) async {
    var url = "$baseUrl$endpoint";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http
        .post(uri, headers: headers, body: jsonRequest)
        .timeout(const Duration(seconds: 10));

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<T> update(int id, [dynamic request]) async {
    var url = "$baseUrl$endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http
        .put(uri, headers: headers, body: jsonRequest)
        .timeout(const Duration(seconds: 10));

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<bool> delete(int id) async {
    var url = "$baseUrl$endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http
        .delete(uri, headers: headers)
        .timeout(const Duration(seconds: 10));

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return data == true;
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<Map<String, dynamic>> post(String subEndpoint, dynamic request) async {
    var url = "$baseUrl$endpoint/$subEndpoint";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http
        .post(uri, headers: headers, body: jsonRequest)
        .timeout(const Duration(seconds: 10));

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<dynamic> postCustom(String subEndpoint, dynamic request) async {
    var url = "$baseUrl$endpoint/$subEndpoint";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http
        .post(uri, headers: headers, body: jsonRequest)
        .timeout(const Duration(seconds: 10));

    if (isValidResponse(response)) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<Map<String, dynamic>> put(String subEndpoint, dynamic request) async {
    var url = "$baseUrl$endpoint/$subEndpoint";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http
        .put(uri, headers: headers, body: jsonRequest)
        .timeout(const Duration(seconds: 10));

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<dynamic> putCustom(String subEndpoint, dynamic request) async {
    var url = "$baseUrl$endpoint/$subEndpoint";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http
        .put(uri, headers: headers, body: jsonRequest)
        .timeout(const Duration(seconds: 10));

    if (isValidResponse(response)) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<void> deleteCustom(String subEndpoint) async {
    var url = "$baseUrl$endpoint/$subEndpoint";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http
        .delete(uri, headers: headers)
        .timeout(const Duration(seconds: 10));

    if (!isValidResponse(response)) {
      throw Exception("Unknown error");
    }
  }

  Future<dynamic> getCustom(
    String subEndpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    var url = "$baseUrl$endpoint/$subEndpoint";

    if (queryParameters != null) {
      var queryString = getQueryString(queryParameters);
      url = "$url?$queryString";
    }

    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 10));

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception("Unknown error");
    }
  }

  T fromJson(data) {
    throw Exception("Method not implemented");
  }

  bool isValidResponse(Response response) {
    if (response.statusCode < 299) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception("Please check your credentials and try again.");
    } else {
      throw Exception("Something went wrong, please try again later!");
    }
  }

  Map<String, String> createHeaders() {
    String username = AuthProvider.username ?? "";
    String password = AuthProvider.password ?? "";

    String basicAuth =
        "Basic ${base64Encode(utf8.encode('$username:$password'))}";

    return {"Content-Type": "application/json", "Authorization": basicAuth};
  }

  String getQueryString(
    Map params, {
    String prefix = '&',
    bool inRecursion = false,
  }) {
    String query = '';
    params.forEach((key, value) {
      if (inRecursion) {
        if (key is int) {
          key = '[$key]';
        } else if (value is List || value is Map) {
          key = '.$key';
        } else {
          key = '.$key';
        }
      }
      if (value is String || value is int || value is double || value is bool) {
        var encoded = value;
        if (value is String) {
          encoded = Uri.encodeComponent(value);
        }
        query += '$prefix$key=$encoded';
      } else if (value is DateTime) {
        query += '$prefix$key=${(value as DateTime).toIso8601String()}';
      } else if (value is List || value is Map) {
        if (value is List) value = value.asMap();
        value.forEach((k, v) {
          query += getQueryString(
            {k: v},
            prefix: '$prefix$key',
            inRecursion: true,
          );
        });
      }
    });
    return query;
  }
}
