import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:smartphone_desktop_admin/providers/auth_provider.dart';
import 'package:smartphone_desktop_admin/model/search_result.dart';

abstract class BaseProvider<T> with ChangeNotifier {
  // Change to protected
  static String? baseUrl;
  @protected
  String endpoint = "";

  BaseProvider(String endpoint) {
    this.endpoint = endpoint;
    baseUrl = const String.fromEnvironment(
      "baseUrl",
      defaultValue: "http://localhost:7074/",
    );
  }

  Future<SearchResult<T>> get({dynamic filter}) async {
    var url = "$baseUrl$endpoint";

    if (filter != null) {
      var queryString = getQueryString(filter);
      url = "$url?$queryString";
    }

    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);

      var result = SearchResult<T>();

      result.totalCount = data['totalCount'];
      result.items = data["items"] != null 
          ? List<T>.from(data["items"].map((e) => fromJson(e)))
          : <T>[];

      return result;
    } else {
      throw new Exception("Unknown error");
    }
    // print("response: ${response.request} ${response.statusCode}, ${response.body}");
  }

  Future<T> insert(dynamic request) async {
    var url = "$baseUrl$endpoint";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http.post(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw new Exception("Unknown error");
    }
  }

  Future<T> update(int id, [dynamic request]) async {
    var url = "$baseUrl$endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http.put(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw new Exception("Unknown error");
    }
  }

  Future<bool> delete(int id) async {
    var url = "$baseUrl$endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.delete(uri, headers: headers);

    if (isValidResponse(response)) {
      // The backend returns a boolean in the response body
      var data = jsonDecode(response.body);
      return data == true;
    } else {
      throw Exception("Unknown error");
    }
  }

  // Custom methods for handling specific endpoints
  Future<Map<String, dynamic>> post(String subEndpoint, dynamic request) async {
    var url = "$baseUrl$endpoint/$subEndpoint";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http.post(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return data;
    } else {
      throw new Exception("Unknown error");
    }
  }

  Future<Map<String, dynamic>> put(String subEndpoint, dynamic request) async {
    var url = "$baseUrl$endpoint/$subEndpoint";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http.put(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return data;
    } else {
      throw new Exception("Unknown error");
    }
  }

  Future<void> deleteCustom(String subEndpoint) async {
    var url = "$baseUrl$endpoint/$subEndpoint";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.delete(uri, headers: headers);

    if (!isValidResponse(response)) {
      throw new Exception("Unknown error");
    }
  }

  Future<dynamic> getCustom(String subEndpoint, {Map<String, dynamic>? queryParameters}) async {
    var url = "$baseUrl$endpoint/$subEndpoint";
    
    if (queryParameters != null) {
      var queryString = getQueryString(queryParameters);
      url = "$url?$queryString";
    }
    
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return data;
    } else {
      throw new Exception("Unknown error");
    }
  }

  T fromJson(data) {
    throw Exception("Method not implemented");
  }

  bool isValidResponse(Response response) {
    if (response.statusCode < 299) {
      return true;
    } else if (response.statusCode == 401) {
      throw new Exception("Please check your credentials and try again.");
    } else {
      throw new Exception("Something went wrong, please try again later!");
    }
  }

  Map<String, String> createHeaders() {
    String username = AuthProvider.username ?? "";
    String password = AuthProvider.password ?? "";

    print("passed creds: $username, $password");

    String basicAuth =
        "Basic ${base64Encode(utf8.encode('$username:$password'))}";

    var headers = {
      "Content-Type": "application/json",
      "Authorization": basicAuth,
    };

    return headers;
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
