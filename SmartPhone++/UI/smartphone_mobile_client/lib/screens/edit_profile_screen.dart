import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartphone_mobile_client/providers/auth_provider.dart';
import 'package:smartphone_mobile_client/providers/user_provider.dart';
import 'package:smartphone_mobile_client/providers/city_provider.dart';
import 'package:smartphone_mobile_client/providers/gender_provider.dart';
import 'package:smartphone_mobile_client/providers/base_provider.dart';
import 'package:smartphone_mobile_client/model/user.dart';
import 'package:smartphone_mobile_client/model/user_upsert_request.dart';
import 'package:smartphone_mobile_client/model/city.dart';
import 'package:smartphone_mobile_client/model/gender.dart';
import 'package:smartphone_mobile_client/model/role_response.dart';
import 'package:smartphone_mobile_client/model/search_result.dart';
import 'dart:convert';

class EditProfileScreen extends StatefulWidget {
  final User user;
  
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  
  int _selectedGenderId = 0;
  int _selectedCityId = 0;
  
  List<Gender> _genders = [];
  List<City> _cities = [];
  
  // Store providers as class variables like in user_details_screen.dart
  late UserProvider _userProvider;
  late CityProvider _cityProvider;
  late GenderProvider _genderProvider;
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeProviders();
    _loadDropdownData();
  }
  
  void _initializeControllers() {
    _firstNameController.text = widget.user.firstName;
    _lastNameController.text = widget.user.lastName;
    _usernameController.text = widget.user.username;
    _emailController.text = widget.user.email;
    _phoneNumberController.text = widget.user.phoneNumber ?? '';
    
    // Don't set dropdown values until data is loaded
    _selectedGenderId = 0;
    _selectedCityId = 0;
  }
  
  void _initializeProviders() {
    // Get providers in initState like in user_details_screen.dart
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _cityProvider = Provider.of<CityProvider>(context, listen: false);
    _genderProvider = Provider.of<GenderProvider>(context, listen: false);
  }
  
  Future<void> _loadDropdownData() async {
    try {
      setState(() => _isLoading = true);
      
      print('Starting to load dropdown data...');
      
      // Initialize base URLs for both providers
      print('Initializing base URLs...');
      try {
        await _genderProvider.initBaseUrl();
        await _cityProvider.initBaseUrl();
        print('Base URLs initialized successfully');
        
        // Debug: Check if we can access the base URL
        print('Testing network connectivity...');
        try {
          final testUrl = Uri.parse('${BaseProvider.baseUrl}api/health');
          print('Testing URL: $testUrl');
          // We'll test this in the actual API calls
        } catch (e) {
          print('Error parsing test URL: $e');
        }
        
        // Debug: Print the actual base URL being used
        print('Current base URL: ${BaseProvider.baseUrl}');
        print('Gender endpoint: ${_genderProvider.endpoint}');
        print('City endpoint: ${_cityProvider.endpoint}');
      } catch (e) {
        print('Error initializing base URLs: $e');
        // Try to continue with default URLs
        print('Attempting to use default URLs...');
      }
      
      // Load genders and cities with proper filters like in user_details_screen.dart
      print('Loading genders...');
      SearchResult<Gender> genderResult;
      try {
        // Try the current endpoint first
        print('Attempting to load genders from endpoint: ${_genderProvider.endpoint}');
        genderResult = await _genderProvider.get(filter: {
          "page": 0,
          "pageSize": 100, // Get all genders
          "includeTotalCount": true,
        });
        print('Genders loaded: ${genderResult.items?.length ?? 0} items');
        
        // If no genders loaded, try without filter
        if (genderResult.items == null || genderResult.items!.isEmpty) {
          print('No genders loaded with filter, trying without filter...');
          genderResult = await _genderProvider.get();
          print('Genders loaded without filter: ${genderResult.items?.length ?? 0} items');
        }
        
        // If still no genders, try different endpoint variations
        if (genderResult.items == null || genderResult.items!.isEmpty) {
          print('Still no genders, checking if endpoint should be different...');
          // Try to manually construct the URL to see what's happening
          final baseUrl = BaseProvider.baseUrl;
          final endpoint = _genderProvider.endpoint;
          print('Full gender URL would be: $baseUrl$endpoint');
          
          // Fallback to hardcoded genders if API fails
          print('Using fallback hardcoded genders...');
          final fallbackGenders = [
            Gender(id: 1, name: 'Male'),
            Gender(id: 2, name: 'Female'),
          ];
          genderResult = SearchResult<Gender>();
          genderResult.items = fallbackGenders;
          print('Fallback genders loaded: ${genderResult.items?.length ?? 0} items');
        }
        
      } catch (e) {
        print('Error loading genders: $e');
        print('Error details: ${e.toString()}');
        // Create empty result
        genderResult = SearchResult<Gender>();
        genderResult.items = [];
      }
      
      print('Loading cities...');
      SearchResult<City> cityResult;
      try {
        cityResult = await _cityProvider.get(filter: {
          "page": 0,
          "pageSize": 100, // Get all cities
          "includeTotalCount": true,
        });
        print('Cities loaded: ${cityResult.items?.length ?? 0} items');
      } catch (e) {
        print('Error loading cities: $e');
        // Create empty result
        cityResult = SearchResult<City>();
        cityResult.items = [];
      }
      
      if (mounted) {
        setState(() {
          _genders = genderResult.items ?? [];
          _cities = cityResult.items ?? [];
          
          // Now set the selected values after data is loaded
          if (_genders.isNotEmpty) {
            _selectedGenderId = widget.user.genderId;
            // Validate that the user's gender exists in the loaded data
            if (!_genders.any((g) => g.id == widget.user.genderId)) {
              _selectedGenderId = _genders.first.id; // Fallback to first available
              print('User gender ID ${widget.user.genderId} not found, using fallback: $_selectedGenderId');
            }
          }
          
          if (_cities.isNotEmpty) {
            _selectedCityId = widget.user.cityId;
            // Validate that the user's city exists in the loaded data
            if (!_cities.any((c) => c.id == widget.user.cityId)) {
              _selectedCityId = _cities.first.id; // Fallback to first available
              print('User city ID ${widget.user.cityId} not found, using fallback: $_selectedCityId');
            }
          }
        });
       
      }
    } catch (e) {
      print('=== ERROR LOADING DROPDOWN DATA ===');
      print('Error: $e');
      print('Error type: ${e.runtimeType}');
      print('Stack trace: ${StackTrace.current}');
      print('===================================');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading dropdown data: $e\n\nPlease check your network connection and try again.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadDropdownData,
              textColor: Colors.white,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDropdownData,
            tooltip: 'Refresh dropdown data',
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture Section
              _buildProfilePictureSection(),
              
              const SizedBox(height: 24),
              
              // Personal Information Section
              _buildSectionTitle('Personal Information'),
              _buildTextField(
                controller: _firstNameController,
                label: 'First Name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'First name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _lastNameController,
                label: 'Last Name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Last name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _usernameController,
                label: 'Username',
                icon: Icons.account_circle,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Username is required';
                  }
                  if (value.length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneNumberController,
                label: 'Phone Number (Optional)',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              
              const SizedBox(height: 24),
              
              // Location & Demographics Section
              _buildSectionTitle('Location & Demographics'),
              if (_cities.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.purple,
                              strokeWidth: 2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Loading dropdown data...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _loadDropdownData,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Retry Loading'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          minimumSize: const Size(0, 32),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Gender Display (Read-Only)
              _buildReadOnlyField(
                label: 'Gender',
                icon: Icons.person_outline,
                value: _getGenderName(widget.user.genderId),
              ),
              const SizedBox(height: 16),
              
              // City Dropdown (Editable)
              _buildDropdownField(
                label: 'City',
                icon: Icons.location_city,
                value: _cities.isEmpty ? null : _selectedCityId,
                items: _cities.isEmpty 
                    ? [DropdownMenuItem<int>(value: null, child: Text('Loading cities...'))]
                    : _cities.map((city) => DropdownMenuItem(
                        value: city.id,
                        child: Text(city.name),
                      )).toList(),
                onChanged: _cities.isEmpty ? null : (value) {
                  setState(() {
                    _selectedCityId = value ?? 0;
                  });
                },
                validator: (value) {
                  if (_cities.isEmpty) return null; // Skip validation while loading
                  if (value == null || value == 0) {
                    return 'Please select a city';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Password Section
              _buildSectionTitle('Change Password (Optional)'),
              _buildPasswordField(
                controller: _passwordController,
                label: 'New Password',
                icon: Icons.lock,
                showPassword: _showPassword,
                onTogglePassword: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    if (_confirmPasswordController.text.isNotEmpty && 
                        value != _confirmPasswordController.text) {
                      return 'Passwords do not match';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: 'Confirm New Password',
                icon: Icons.lock_outline,
                showPassword: _showConfirmPassword,
                onTogglePassword: () {
                  setState(() {
                    _showConfirmPassword = !_showConfirmPassword;
                  });
                },
                validator: (value) {
                  if (_passwordController.text.isNotEmpty) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Roles Section
              _buildSectionTitle('User Roles (Read-Only)'),
              _buildRolesSection(),
              
              const SizedBox(height: 32),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveProfile,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Changes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _cancelEdit,
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildProfilePictureSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.purple.withOpacity(0.1),
                child: widget.user.picture != null && widget.user.picture!.isNotEmpty
                    ? ClipOval(
                        child: Image.memory(
                          base64Decode(widget.user.picture!),
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.purple,
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    onPressed: () {
                      // TODO: Implement image picker
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Image picker functionality coming soon...'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tap camera icon to change profile picture',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.purple,
        ),
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.purple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.purple, width: 2),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required IconData icon,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color.fromARGB(255, 94, 91, 91),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300] ?? Colors.grey),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.purple, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required int? value,
    required List<DropdownMenuItem<int>> items,
    required void Function(int?)? onChanged,
    String? Function(int?)? validator,
  }) {
    return DropdownButtonFormField<int>(
      value: value == 0 ? null : value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.purple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.purple, width: 2),
        ),
      ),
    );
  }
  
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool showPassword,
    required VoidCallback onTogglePassword,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !showPassword,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.purple),
        suffixIcon: IconButton(
          icon: Icon(
            showPassword ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: onTogglePassword,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.purple, width: 2),
        ),
      ),
    );
  }
  
  Widget _buildRolesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Roles:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.user.roles?.map((role) {
              return FilterChip(
                label: Text(role.name),
                selected: true, // Make roles read-only
                onSelected: null, // No selection allowed
                selectedColor: Colors.purple.withOpacity(0.2),
                checkmarkColor: Colors.purple,
                backgroundColor: Colors.grey[200],
                labelStyle: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.normal,
                ),
              );
            }).toList() ?? [],
          ),
          const SizedBox(height: 8),
          Text(
            'Your roles cannot be changed.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Additional validation for dropdown values
    if (_cities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for dropdown data to load before saving'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    if (_selectedCityId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a city'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      await _userProvider.initBaseUrl();
      
      final request = UserUpsertRequest(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim().isEmpty 
            ? null 
            : _phoneNumberController.text.trim(),
        genderId: widget.user.genderId, // Keep existing gender
        cityId: _selectedCityId,
        isActive: widget.user.isActive,
        password: _passwordController.text.isNotEmpty 
            ? _passwordController.text 
            : null,
        roleIds: widget.user.roles?.map((role) => role.id).toList() ?? [], // Keep existing roles
        picture: widget.user.picture, // Keep existing picture for now
      );
      
      final updatedUser = await _userProvider.update(widget.user.id, request);
      
      // Update the auth provider with the new user data
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.updateCurrentUser(updatedUser);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.of(context).pop();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void _cancelEdit() {
    Navigator.of(context).pop();
  }

  String _getGenderName(int genderId) {
    // Simple fallback to hardcoded gender names
    switch (genderId) {
      case 1:
        return 'Male';
      case 2:
        return 'Female';
      default:
        return 'Unknown';
    }
  }
}
