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
  User? user;
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

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    cityProvider = Provider.of<CityProvider>(context, listen: false);
    
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
      "password": widget.user == null ? '' : '', // Will be auto-generated for new users
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
      var citiesResult = await cityProvider.get(filter: {
        "page": 0,
        "pageSize": 100, // Get all cities
        "includeTotalCount": true,
      });
      
      // Fetch roles from the database (if RoleProvider is available)
      List<RoleResponse> rolesResult = [];
      
      if (roleProvider != null) {
        try {
          var rolesData = await roleProvider.get(filter: {
            "page": 0,
            "pageSize": 100, // Get all roles
            "includeTotalCount": true,
          });
          rolesResult = rolesData.items ?? [];
        } catch (e) {
          rolesResult = [];
        }
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
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
        constraints: BoxConstraints(maxWidth: 420),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 32.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomPictureDesign(
                  base64: widget.user!.picture,
                  size: 140,
                  fallbackIcon: Icons.account_circle,
                ),
                SizedBox(height: 18),
                Text(
                  "${widget.user!.firstName} ${widget.user!.lastName}",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  "@${widget.user!.username}",
                  style: TextStyle(fontSize: 16, color: Colors.blueGrey[700]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 18),
                _buildInfoRow("Email", widget.user!.email, icon: Icons.email),
                _buildInfoRow(
                  "Phone",
                  widget.user!.phoneNumber ?? '-',
                  icon: Icons.phone,
                ),
                _buildInfoRow(
                  "Gender",
                  widget.user!.genderName,
                  icon: Icons.person_outline,
                ),
                _buildInfoRow(
                  "City",
                  widget.user!.cityName,
                  icon: Icons.location_city,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified_user,
                        size: 20,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Active:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        widget.user!.isActive ? Icons.check_circle : Icons.cancel,
                        color: widget.user!.isActive ? Colors.green : Colors.red,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.orange),
            SizedBox(width: 8),
          ],
          Text(
            "$label:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.cancel),
          label: Text("Cancel"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            foregroundColor: Colors.black87,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        SizedBox(width: 12),
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
                if (widget.user == null) {
                  widget.user = await userProvider.insert(request);
                } else {
                  widget.user = await userProvider.update(
                    widget.user!.id,
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
          icon: Icon(Icons.save),
          label: Text("Save"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 500),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: FormBuilder(
                key: formKey,
                initialValue: _initialValue,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'User Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
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
                          errorText: 'Only letters, numbers, and underscores allowed',
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
                        FormBuilderValidators.minLength(6, errorText: 'Password must be at least 6 characters'),
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
                              DropdownMenuItem(value: 2, child: Text("Female")),
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
                            items: cities.map((city) => DropdownMenuItem(value: city.id, child: Text(city.name))).toList(),
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
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          options: roles.map((role) => FormBuilderFieldOption(
                            value: role.id,
                            child: Text(role.name),
                          )).toList(),
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
    );
  }
}
