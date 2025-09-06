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
      defaultValue: "http://localhost:5130/",
    );

    print(
      "BaseProvider: Created for endpoint '$endpoint' with baseUrl: $baseUrl",
    );
    print(
      "BaseProvider: Auth status - username: ${AuthProvider.username != null ? 'set' : 'null'}, password: ${AuthProvider.password != null ? 'set' : 'null'}",
    );
  }

  Future<SearchResult<T>> get({dynamic filter}) async {
    // Check if authentication is ready before making the request
    if (!isAuthenticated) {
      print(
        "ERROR: Authentication not ready. Username: ${AuthProvider.username}, Password: ${AuthProvider.password != null ? '***' : 'null'}",
      );
      throw new Exception("Authentication not ready. Please log in again.");
    }

    var url = "$baseUrl$endpoint";

    if (filter != null) {
      var queryString = getQueryString(filter);
      url = "$url?$queryString";
    }

    var uri = Uri.parse(url);
    var headers = createHeaders();

    print(
      "Making GET request to: $url with auth: ${headers['Authorization']?.substring(0, 20)}...",
    );

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

  Future<T?> getById(int id) async {
    // Check if authentication is ready before making the request
    if (!isAuthenticated) {
      print(
        "ERROR: Authentication not ready. Username: ${AuthProvider.username}, Password: ${AuthProvider.password != null ? '***' : 'null'}",
      );
      throw new Exception("Authentication not ready. Please log in again.");
    }

    var url = "$baseUrl$endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    print(
      "Making GET request to: $url with auth: ${headers['Authorization']?.substring(0, 20)}...",
    );

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      if (data == null) return null;
      return fromJson(data);
    } else {
      throw new Exception("Unknown error");
    }
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
      // Handle empty response body (common for successful DELETE operations)
      if (response.body.isEmpty) {
        return true;
      }

      try {
        // The backend might return a boolean in the response body
        var data = jsonDecode(response.body);
        return data == true;
      } catch (e) {
        // If JSON parsing fails but response is successful, assume deletion was successful
        print(
          "Warning: Could not parse delete response as JSON, but operation was successful: $e",
        );
        return true;
      }
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

  // Custom POST that returns raw decoded JSON (can be bool, list, map, etc.)
  Future<dynamic> postCustom(String subEndpoint, dynamic request) async {
    var url = "$baseUrl$endpoint/$subEndpoint";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http.post(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      return jsonDecode(response.body);
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

  // Custom PUT that returns raw decoded JSON (can be bool, list, map, etc.)
  Future<dynamic> putCustom(String subEndpoint, dynamic request) async {
    var url = "$baseUrl$endpoint/$subEndpoint";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http.put(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      return jsonDecode(response.body);
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
    // No need to parse response body for void return type
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

  // Check if authentication is ready
  bool get isAuthenticated {
    return AuthProvider.username != null &&
        AuthProvider.username!.isNotEmpty &&
        AuthProvider.password != null &&
        AuthProvider.password!.isNotEmpty;
  }

  Map<String, String> createHeaders() {
    // Get credentials from AuthProvider instance if available
    String username = "";
    String password = "";

    try {
      // Try to get credentials from static properties first
      if (AuthProvider.username != null && AuthProvider.password != null) {
        username = AuthProvider.username!;
        password = AuthProvider.password!;
      }
    } catch (e) {
      print("Warning: Could not access AuthProvider credentials: $e");
    }

    print("passed creds: $username, $password");

    if (username.isEmpty || password.isEmpty) {
      throw Exception(
        "Authentication credentials not available. Please log in again.",
      );
    }

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
        query += '$prefix$key=${value.toIso8601String()}';
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
