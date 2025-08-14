import 'package:flutter/foundation.dart';
import 'package:smartphone_mobile_client/model/user.dart';
import 'package:smartphone_mobile_client/providers/base_provider.dart';
import 'dart:convert';

class AuthProvider extends BaseProvider<User> {
  static String? username;
  static String? password;
  
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  AuthProvider() : super("Users");

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

      // Initialize base URL first
      await initBaseUrl();
      
      // Use the custom endpoint to get current user info
      final response = await getCustom('me');
      
      if (response != null) {
        _currentUser = User.fromJson(response);
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Authentication failed: No user data received';
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

  @override
  User fromJson(dynamic data) {
    return User.fromJson(data);
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