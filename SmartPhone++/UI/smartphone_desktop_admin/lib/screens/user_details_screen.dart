import 'dart:convert';
import 'dart:io';

import 'package:smartphone_desktop_admin/layouts/master_screen.dart';
import 'package:smartphone_desktop_admin/model/user.dart';
import 'package:smartphone_desktop_admin/model/city.dart';
import 'package:smartphone_desktop_admin/model/role_response.dart';
import 'package:smartphone_desktop_admin/providers/user_provider.dart';
import 'package:smartphone_desktop_admin/providers/city_provider.dart';
import 'package:smartphone_desktop_admin/providers/role_provider.dart';
import 'package:smartphone_desktop_admin/screens/user_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:file_picker/file_picker.dart';
import 'package:smartphone_desktop_admin/utils/text_field_decoration.dart';
import 'package:smartphone_desktop_admin/utils/custom_picture_design.dart';

class UserDetailsScreen extends StatefulWidget {
  final User? user;
  UserDetailsScreen({super.key, this.user});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final formKey = GlobalKey<FormBuilderState>();

  Map<String, dynamic> _initialValue = {};

  late UserProvider userProvider;
  late CityProvider cityProvider;
  late RoleProvider roleProvider;

  bool isLoading = true;
  List<City> cities = [];
  List<RoleResponse> roles = [];
  String? selectedPictureBase64;
  User? _currentUser; // Local variable to track current user

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    cityProvider = Provider.of<CityProvider>(context, listen: false);

    // Initialize current user
    _currentUser = widget.user;

    // Try to get RoleProvider, but don't crash if it's not available
    try {
      roleProvider = Provider.of<RoleProvider>(context, listen: false);
    } catch (e) {
      // Create a temporary role provider
      roleProvider = RoleProvider();
    }

    _initialValue = {
      "firstName": widget.user?.firstName ?? '',
      "lastName": widget.user?.lastName ?? '',
      "email": widget.user?.email ?? '',
      "username": widget.user?.username ?? '',
      "password": widget.user == null
          ? ''
          : '', // Will be auto-generated for new users
      "phoneNumber": widget.user?.phoneNumber ?? '',
      "isActive": widget.user?.isActive ?? true,
      "genderId": widget.user?.genderId ?? 1,
      "cityId": widget.user?.cityId ?? 1,
      "roleIds": widget.user?.roles.map((r) => r.id).toList() ?? [],
    };

    // Set initial picture if editing existing user
    if (widget.user?.picture != null) {
      selectedPictureBase64 = widget.user!.picture;
    }

    initFormData();
  }

  initFormData() async {
    try {
      // Fetch cities from the database
      var citiesResult = await cityProvider.get(
        filter: {
          "page": 0,
          "pageSize": 100, // Get all cities
          "includeTotalCount": true,
        },
      );

      // Fetch roles from the database
      List<RoleResponse> rolesResult = [];

      try {
        var rolesData = await roleProvider.get(
          filter: {
            "page": 0,
            "pageSize": 100, // Get all roles
            "includeTotalCount": true,
          },
        );
        rolesResult = rolesData.items ?? [];
      } catch (e) {
        rolesResult = [];
      }

      setState(() {
        cities = citiesResult.items ?? [];
        roles = rolesResult;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
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
          selectedPictureBase64 = base64String;
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  void _autoGenerateCredentials(String? firstName) {
    if (widget.user == null && firstName != null && firstName.isNotEmpty) {
      // Only auto-generate for new users
      final username = firstName.toLowerCase();
      final password = '${firstName.toLowerCase()}123';

      formKey.currentState?.fields['username']?.didChange(username);
      formKey.currentState?.fields['password']?.didChange(password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: widget.user == null ? "Add New User" : "User Details",
      showBackButton: true,
      child: widget.user == null ? _buildForm() : _buildDetailsView(),
    );
  }

  Widget _buildDetailsView() {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 480),
        child: Card(
          elevation: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey[100]!, Colors.grey[200]!],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 36.0,
                vertical: 36.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Picture with Purple Border
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.purple[400]!,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: CustomPictureDesign(
                          base64: _currentUser!.picture,
                          size: 160,
                          fallbackIcon: Icons.account_circle,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Name with Purple Styling
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${_currentUser!.firstName} ${_currentUser!.lastName}",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 8),

                    // Username with Purple Accent
                    Text(
                      "@${_currentUser!.username}",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.purple[600],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),

                    // Info Rows with Purple Theme
                    _buildInfoRow(
                      "Email",
                      _currentUser!.email,
                      icon: Icons.email,
                    ),
                    _buildInfoRow(
                      "Phone",
                      _currentUser!.phoneNumber ?? '-',
                      icon: Icons.phone,
                    ),
                    _buildInfoRow(
                      "Gender",
                      _currentUser!.genderName,
                      icon: Icons.person_outline,
                    ),
                    _buildInfoRow(
                      "City",
                      _currentUser!.cityName,
                      icon: Icons.location_city,
                    ),

                    // Active Status with Purple Theme
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 12),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _currentUser!.isActive
                            ? Colors.green[50]
                            : Colors.red[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _currentUser!.isActive
                              ? Colors.green[300]!
                              : Colors.red[300]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user,
                            size: 20,
                            color: _currentUser!.isActive
                                ? Colors.green[600]
                                : Colors.red[600],
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Status:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _currentUser!.isActive
                                  ? Colors.green[700]
                                  : Colors.red[700],
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            _currentUser!.isActive ? "Active" : "Inactive",
                            style: TextStyle(
                              fontSize: 16,
                              color: _currentUser!.isActive
                                  ? Colors.green[700]
                                  : Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Back Button
                        ElevatedButton.icon(
                          onPressed: () {
                            // Navigate back to user list
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          label: Text(
                            "Back",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[600],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 4,
                          ),
                        ),

                        // Delete Button
                        ElevatedButton.icon(
                          onPressed: () => _showDeleteConfirmation(),
                          icon: Icon(Icons.delete, color: Colors.white),
                          label: Text(
                            "Delete",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20), // Add extra padding at bottom
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple[200]!, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 22, color: Colors.purple[600]),
            SizedBox(width: 12),
          ],
          Text(
            "$label:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.purple[700],
            ),
          ),
          SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.purple[800]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red[600], size: 28),
              SizedBox(width: 12),
              Text(
                'Delete User',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${_currentUser!.firstName} ${_currentUser!.lastName}"?\n\nThis action cannot be undone.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteUser();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Delete', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUser() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.purple[600]!,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Deleting user...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        },
      );

      // Delete the user
      await userProvider.delete(_currentUser!.id);

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'User "${_currentUser!.firstName} ${_currentUser!.lastName}" has been deleted successfully.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green[600],
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // Navigate back to user list
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const UserListScreen()),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete user: ${e.toString().replaceFirst('Exception: ', '')}',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[600],
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Widget _buildSaveButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.cancel, color: Colors.white),
          label: Text("Cancel", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[600],
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 4,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            formKey.currentState?.saveAndValidate();
            if (formKey.currentState?.validate() ?? false) {
              print(formKey.currentState?.value.toString());
              var request = Map.from(formKey.currentState?.value ?? {});

              // Remove confirmPassword from request as it's only for validation
              request.remove('confirmPassword');

              // Add picture to request if selected
              if (selectedPictureBase64 != null) {
                request['picture'] = selectedPictureBase64;
              }

              try {
                if (_currentUser == null) {
                  _currentUser = await userProvider.insert(request);
                } else {
                  _currentUser = await userProvider.update(
                    _currentUser!.id,
                    request,
                  );
                }
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const UserListScreen(),
                  ),
                );
              } catch (e) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Error'),
                    content: Text(e.toString().replaceFirst('Exception: ', '')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            }
          },
          icon: Icon(Icons.save, color: Colors.white),
          label: Text("Save", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple[600],
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[600]!),
        ),
      );
    }

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 500),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.purple[50]!, Colors.purple[100]!],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: FormBuilder(
                  key: formKey,
                  initialValue: _initialValue,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple[100],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          'User Information',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Colors.purple[800],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: FormBuilderTextField(
                              name: "firstName",
                              decoration: customTextFieldDecoration(
                                "First Name",
                                prefixIcon: Icons.person,
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                FormBuilderValidators.match(
                                  RegExp(r'^[A-Za-z\s]+'),
                                  errorText: 'Only letters and spaces allowed',
                                ),
                              ]),
                              onChanged: (value) {
                                _autoGenerateCredentials(value);
                              },
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: FormBuilderTextField(
                              name: "lastName",
                              decoration: customTextFieldDecoration(
                                "Last Name",
                                prefixIcon: Icons.person,
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                FormBuilderValidators.match(
                                  RegExp(r'^[A-Za-z\s]+'),
                                  errorText: 'Only letters and spaces allowed',
                                ),
                              ]),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      FormBuilderTextField(
                        name: "email",
                        decoration: customTextFieldDecoration(
                          "Email",
                          prefixIcon: Icons.email,
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.email(),
                        ]),
                      ),
                      SizedBox(height: 16),
                      FormBuilderTextField(
                        name: "username",
                        decoration: customTextFieldDecoration(
                          "Username",
                          prefixIcon: Icons.account_circle,
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.match(
                            RegExp(r'^[a-zA-Z0-9_]+'),
                            errorText:
                                'Only letters, numbers, and underscores allowed',
                          ),
                        ]),
                      ),
                      SizedBox(height: 16),
                      FormBuilderTextField(
                        name: "password",
                        decoration: customTextFieldDecoration(
                          "Password",
                          prefixIcon: Icons.lock,
                        ),
                        obscureText: false, // Make password visible
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.minLength(
                            6,
                            errorText: 'Password must be at least 6 characters',
                          ),
                        ]),
                      ),
                      SizedBox(height: 16),
                      // Removed confirmPassword field
                      FormBuilderTextField(
                        name: "phoneNumber",
                        decoration: customTextFieldDecoration(
                          "Phone Number",
                          prefixIcon: Icons.phone,
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.match(
                            RegExp(r'^\+?[0-9\s\-\(\)]+'),
                            errorText: 'Please enter a valid phone number',
                          ),
                        ]),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: FormBuilderDropdown<int>(
                              name: "genderId",
                              decoration: customTextFieldDecoration(
                                "Gender",
                                prefixIcon: Icons.person_outline,
                              ),
                              items: [
                                DropdownMenuItem(value: 1, child: Text("Male")),
                                DropdownMenuItem(
                                  value: 2,
                                  child: Text("Female"),
                                ),
                              ],
                              validator: FormBuilderValidators.required(),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: FormBuilderDropdown<int>(
                              name: "cityId",
                              decoration: customTextFieldDecoration(
                                "City",
                                prefixIcon: Icons.location_city,
                              ),
                              items: cities
                                  .map(
                                    (city) => DropdownMenuItem(
                                      value: city.id,
                                      child: Text(city.name),
                                    ),
                                  )
                                  .toList(),
                              validator: FormBuilderValidators.required(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      FormBuilderCheckbox(
                        name: "isActive",
                        title: Text("Active"),
                        initialValue: true,
                      ),
                      SizedBox(height: 16),
                      // Role selection section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Roles",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          FormBuilderCheckboxGroup<int>(
                            name: "roleIds",
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            options: roles
                                .map(
                                  (role) => FormBuilderFieldOption(
                                    value: role.id,
                                    child: Text(role.name),
                                  ),
                                )
                                .toList(),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                            ]),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      // Picture upload section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Profile Picture",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              // Picture preview
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: selectedPictureBase64 != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.memory(
                                          base64Decode(selectedPictureBase64!),
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Icon(
                                        Icons.account_circle,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                              ),
                              SizedBox(width: 16),
                              // Upload button
                              ElevatedButton.icon(
                                onPressed: _pickImage,
                                icon: Icon(Icons.upload),
                                label: Text("Choose Picture"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              // Remove button (only show if picture is selected)
                              if (selectedPictureBase64 != null)
                                ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      selectedPictureBase64 = null;
                                    });
                                  },
                                  icon: Icon(Icons.delete),
                                  label: Text("Remove"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 50),
                      _buildSaveButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
