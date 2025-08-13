import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartphone_mobile_client/model/user_upsert_request.dart';
import 'package:smartphone_mobile_client/model/city.dart';
import 'package:smartphone_mobile_client/model/gender.dart';
import 'package:smartphone_mobile_client/providers/city_provider.dart';
import 'package:smartphone_mobile_client/providers/gender_provider.dart';
import 'package:smartphone_mobile_client/providers/user_provider.dart';
import 'package:smartphone_mobile_client/utils/text_field_decoration.dart';
import 'package:file_picker/file_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  List<City> _cities = [];
  List<Gender> _genders = [];
  City? _selectedCity;
  Gender? _selectedGender;
  String? _selectedPictureBase64;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final cityProvider = Provider.of<CityProvider>(context, listen: false);
      final genderProvider = Provider.of<GenderProvider>(context, listen: false);
      
      await cityProvider.initBaseUrl();
      await genderProvider.initBaseUrl();
      
      final cityResult = await cityProvider.get();
      final genderResult = await genderProvider.get();
      
      setState(() {
        _cities = cityResult.items ?? [];
        _genders = genderResult.items ?? [];
        
        // Set default selections if available
        if (_cities.isNotEmpty) _selectedCity = _cities.first;
        if (_genders.isNotEmpty) _selectedGender = _genders.first;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);
        
        setState(() {
          _selectedPictureBase64 = base64String;
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCity == null || _selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select city and gender')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.initBaseUrl();

      final request = UserUpsertRequest(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        phoneNumber: _phoneNumberController.text.trim().isEmpty 
            ? null 
            : _phoneNumberController.text.trim(),
        picture: _selectedPictureBase64,
        genderId: _selectedGender!.id,
        cityId: _selectedCity!.id,
        roleIds: [1], // Assuming role ID 1 is "User" role
      );

      await userProvider.insert(request);

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );
      
      Navigator.of(context).pop(); // Go back to login screen
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  // Logo
                  Center(
                    child: Image.asset(
                      "assets/images/smartphone_logo.png",
                      height: 100,
                      width: 100,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Profile Picture Picker
                  Center(
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.purple[400]!,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _selectedPictureBase64 != null
                                ? Image.memory(
                                    base64Decode(_selectedPictureBase64!),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey[200],
                                    child: Icon(
                                      Icons.account_circle,
                                      size: 60,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: Icon(Icons.camera_alt, size: 18),
                              label: Text("Add Photo", style: TextStyle(fontSize: 14)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            if (_selectedPictureBase64 != null) ...[
                              SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _selectedPictureBase64 = null;
                                  });
                                },
                                icon: Icon(Icons.delete, size: 18),
                                label: Text("Remove", style: TextStyle(fontSize: 14)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[600],
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // First Name
                  TextFormField(
                    controller: _firstNameController,
                    decoration: customTextFieldDecoration(
                      "First Name",
                      prefixIcon: Icons.person,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'First name is required';
                      }
                      if (value.trim().length > 50) {
                        return 'First name must be less than 50 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Last Name
                  TextFormField(
                    controller: _lastNameController,
                    decoration: customTextFieldDecoration(
                      "Last Name",
                      prefixIcon: Icons.person,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Last name is required';
                      }
                      if (value.trim().length > 50) {
                        return 'Last name must be less than 50 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: customTextFieldDecoration(
                      "Email",
                      prefixIcon: Icons.email,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Username
                  TextFormField(
                    controller: _usernameController,
                    decoration: customTextFieldDecoration(
                      "Username",
                      prefixIcon: Icons.account_circle,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Username is required';
                      }
                      if (value.trim().length > 100) {
                        return 'Username must be less than 100 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: customTextFieldDecoration(
                      "Password",
                      prefixIcon: Icons.lock,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 4) {
                        return 'Password must be at least 4 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Confirm Password
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: customTextFieldDecoration(
                      "Confirm Password",
                      prefixIcon: Icons.lock,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Phone Number (Optional)
                  TextFormField(
                    controller: _phoneNumberController,
                    keyboardType: TextInputType.phone,
                    decoration: customTextFieldDecoration(
                      "Phone Number (Optional)",
                      prefixIcon: Icons.phone,
                    ),
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        if (value.trim().length > 20) {
                          return 'Phone number must be less than 20 characters';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Gender Dropdown
                  DropdownButtonFormField<Gender>(
                    value: _selectedGender,
                    decoration: customTextFieldDecoration(
                      "Gender",
                      prefixIcon: Icons.person_outline,
                    ),
                    items: _genders.map((gender) {
                      return DropdownMenuItem(
                        value: gender,
                        child: Text(gender.name),
                      );
                    }).toList(),
                    onChanged: (Gender? value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a gender';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // City Dropdown
                  DropdownButtonFormField<City>(
                    value: _selectedCity,
                    decoration: customTextFieldDecoration(
                      "City",
                      prefixIcon: Icons.location_city,
                    ),
                    items: _cities.map((city) {
                      return DropdownMenuItem(
                        value: city,
                        child: Text(city.name),
                      );
                    }).toList(),
                    onChanged: (City? value) {
                      setState(() {
                        _selectedCity = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a city';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  // Register Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.purple,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }
}
