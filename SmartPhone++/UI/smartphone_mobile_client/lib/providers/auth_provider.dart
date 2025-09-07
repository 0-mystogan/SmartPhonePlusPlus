import 'package:smartphone_mobile_client/model/user.dart';
import 'package:smartphone_mobile_client/providers/base_provider.dart';

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
    return _currentUser!.roles.any(
      (role) => role.name.toLowerCase() == roleName.toLowerCase(),
    );
  }

  // Check if user is a technician
  bool get isTechnician => hasRole('Technician');

  // Check if user is an administrator
  bool get isAdministrator => hasRole('Administrator');

  // Check if user is a regular user
  bool get isUser => hasRole('User');

  // Authenticate user
  Future<bool> authenticate(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('AuthProvider: Starting authentication for username: $username');

      // Set credentials first (like the working desktop version)
      AuthProvider.username = username;
      AuthProvider.password = password;

      // Initialize base URL first
      print('AuthProvider: Initializing base URL...');
      await initBaseUrl();
      print('AuthProvider: Base URL initialized successfully');

      // Now call the /me endpoint with the credentials set (like desktop version)
      print('AuthProvider: Making request to /api/Users/me');
      final response = await getCustom('me');

      print('AuthProvider: /me response received: $response');

      if (response != null) {
        _currentUser = User.fromJson(response);
        _isAuthenticated = true;
        _isLoading = false;
        print(
          'AuthProvider: Authentication successful for user: ${_currentUser?.username}',
        );
        notifyListeners();
        return true;
      } else {
        _error = 'Authentication failed: No user data received';
        _isAuthenticated = false;
        _isLoading = false;
        print('AuthProvider: Authentication failed - no user data received');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Authentication error: $e';
      _isAuthenticated = false;
      _isLoading = false;
      print('AuthProvider: Authentication error: $e');
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

  // Update current user data
  void updateCurrentUser(User updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }
}
