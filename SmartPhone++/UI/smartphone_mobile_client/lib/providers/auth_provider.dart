import 'package:flutter/foundation.dart';
import 'package:smartphone_desktop_admin/model/user.dart';
import 'package:smartphone_desktop_admin/providers/base_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthProvider extends ChangeNotifier {
  static String? username;
  static String? password;
  
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Check if user has a specific role
  bool hasRole(String roleName) {
    if (_currentUser == null || _currentUser!.roles.isEmpty) return false;
    return _currentUser!.roles.any((role) => role.name.toLowerCase() == roleName.toLowerCase());
  }

  // Check if user is a technician
  bool get isTechnician => hasRole('Technician');
  
  // Check if user is an administrator
  bool get isAdministrator => hasRole('Administrator');

  // Authenticate user
  Future<bool> authenticate(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      AuthProvider.username = username;
      AuthProvider.password = password;

      // Create basic auth header
      String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
      
      // Make authentication request to get user info
      final response = await http.get(
        Uri.parse('http://localhost:7074/Users/me'),
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        _currentUser = User.fromJson(userData);
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Authentication failed: ${response.statusCode}';
        _isAuthenticated = false;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Authentication error: $e';
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  void logout() {
    _currentUser = null;
    _isAuthenticated = false;
    _error = null;
    AuthProvider.username = null;
    AuthProvider.password = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}