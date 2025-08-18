import 'package:smartphone_desktop_admin/layouts/master_screen.dart';
import 'package:smartphone_desktop_admin/model/service.dart';
import 'package:smartphone_desktop_admin/model/user.dart';
import 'package:smartphone_desktop_admin/model/phone_model.dart';
import 'package:smartphone_desktop_admin/providers/service_provider.dart';
import 'package:smartphone_desktop_admin/providers/user_provider.dart';
import 'package:smartphone_desktop_admin/providers/phone_model_provider.dart';
import 'package:smartphone_desktop_admin/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartphone_desktop_admin/utils/text_field_decoration.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final Service service;
  const ServiceDetailsScreen({super.key, required this.service});

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  late ServiceProvider serviceProvider;
  late UserProvider userProvider;
  late PhoneModelProvider phoneModelProvider;
  late AuthProvider authProvider;
  
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _serviceFeeController;
  late TextEditingController _estimatedDurationController;
  late TextEditingController _customerNotesController;
  late TextEditingController _technicianNotesController;
  late TextEditingController _phoneModelSearchController;
  
  String _status = '';
  int? _selectedUserId;
  int? _selectedPhoneModelId;
  
  List<User> _users = [];
  List<PhoneModel> _phoneModels = [];
  List<PhoneModel> _filteredPhoneModels = [];
  bool _isLoading = false;
  bool _isPhoneModelDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      serviceProvider = context.read<ServiceProvider>();
      userProvider = context.read<UserProvider>();
      phoneModelProvider = context.read<PhoneModelProvider>();
      authProvider = context.read<AuthProvider>();
      _initializeControllers();
      await _loadData();
    });
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.service.name);
    _descriptionController = TextEditingController(text: widget.service.description ?? '');
    _serviceFeeController = TextEditingController(text: widget.service.serviceFee.toString());
    _estimatedDurationController = TextEditingController(
      text: widget.service.estimatedDuration?.toString() ?? ''
    );
    _customerNotesController = TextEditingController(text: widget.service.customerNotes ?? '');
    _technicianNotesController = TextEditingController(text: widget.service.technicianNotes ?? '');
    _phoneModelSearchController = TextEditingController();
    
    _status = widget.service.status;
    _selectedUserId = widget.service.userId == 0 ? null : widget.service.userId;
    _selectedPhoneModelId = widget.service.phoneModelId;
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load users with role 'User'
      var userResult = await userProvider.get(filter: {
        "page": 0,
        "pageSize": 1000,
        "includeTotalCount": true,
        "role": "User"
      });
      
      // Load phone models
      var phoneModelResult = await phoneModelProvider.get(filter: {
        "page": 0,
        "pageSize": 1000,
        "includeTotalCount": true,
      });
      
      setState(() {
        _users = userResult.items ?? [];
        _phoneModels = phoneModelResult.items ?? [];
        _filteredPhoneModels = _phoneModels;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _generateServiceNumber() {
    // Generate service number based on current timestamp
    final now = DateTime.now();
    return 'SRV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
  }

  void _filterPhoneModels(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPhoneModels = _phoneModels;
      } else {
        _filteredPhoneModels = _phoneModels.where((model) =>
          model.model.toLowerCase().contains(query.toLowerCase()) ||
          model.brand.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
    });
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      // For new services, store service number in description field
      String? description;
      if (widget.service.id == 0) {
        // New service - store service number in description
        description = _generateServiceNumber();
      } else {
        // Existing service - keep original description
        description = _descriptionController.text.isEmpty ? null : _descriptionController.text;
      }

      final updatedService = Service(
        id: widget.service.id,
        name: _nameController.text,
        description: description,
        serviceFee: double.tryParse(_serviceFeeController.text) ?? 0.0,
        estimatedDuration: double.tryParse(_estimatedDurationController.text),
        status: _status,
        customerNotes: _customerNotesController.text.isEmpty ? null : _customerNotesController.text,
        technicianNotes: _technicianNotesController.text.isEmpty ? null : _technicianNotesController.text,
        createdAt: widget.service.createdAt,
        updatedAt: DateTime.now(),
        startedAt: widget.service.startedAt,
        completedAt: widget.service.completedAt,
        userId: _selectedUserId ?? 0,
        technicianId: widget.service.id == 0 ? authProvider.currentUser?.id : widget.service.technicianId, // Use logged-in user for new services
        phoneModelId: _selectedPhoneModelId,
      );
      
      if (widget.service.id == 0) {
        // New service
        await serviceProvider.insert(updatedService.toJson());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Service created successfully')),
        );
      } else {
        // Update existing service
        await serviceProvider.update(updatedService.id, updatedService.toJson());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Service updated successfully')),
        );
      }
      
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving service: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _changeStatus(String newStatus) async {
    setState(() => _isLoading = true);
    
    try {
      DateTime? startedAt = widget.service.startedAt;
      DateTime? completedAt = widget.service.completedAt;
      
      if (newStatus == 'In Progress' && startedAt == null) {
        startedAt = DateTime.now();
      } else if (newStatus == 'Completed' && completedAt == null) {
        completedAt = DateTime.now();
      }
      
      final updatedService = Service(
        id: widget.service.id,
        name: widget.service.name,
        description: widget.service.description, // Keep existing description
        serviceFee: widget.service.serviceFee,
        estimatedDuration: widget.service.estimatedDuration,
        status: newStatus,
        customerNotes: widget.service.customerNotes,
        technicianNotes: widget.service.technicianNotes,
        createdAt: widget.service.createdAt,
        updatedAt: DateTime.now(),
        startedAt: startedAt,
        completedAt: completedAt,
        userId: widget.service.userId,
        technicianId: widget.service.technicianId ?? authProvider.currentUser?.id, // Use logged-in user if no technician assigned
        phoneModelId: widget.service.phoneModelId,
      );
      
      await serviceProvider.update(updatedService.id, updatedService.toJson());
      
      setState(() {
        _status = newStatus;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status changed to $newStatus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error changing status: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildStatusButton() {
    Color buttonColor;
    String buttonText;
    String? nextStatus;
    
    switch (_status) {
      case 'Pending':
        buttonColor = Colors.orange;
        buttonText = 'Start Service';
        nextStatus = 'In Progress';
        break;
      case 'In Progress':
        buttonColor = Colors.green;
        buttonText = 'Complete Service';
        nextStatus = 'Completed';
        break;
      case 'Completed':
        buttonColor = Colors.grey;
        buttonText = 'Already Completed';
        nextStatus = null;
        break;
      default:
        buttonColor = Colors.blue;
        buttonText = 'Change Status';
        nextStatus = 'In Progress';
    }
    
    return ElevatedButton(
      onPressed: nextStatus == null ? null : () => _changeStatus(nextStatus!),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Text(buttonText),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: widget.service.id == 0 ? "New Service" : "Edit Service",
      showBackButton: true,
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 36.0,
                  vertical: 36.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        widget.service.id == 0 ? "New Service" : "Edit Service",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                        ),
                      ),
                      SizedBox(height: 24),
                      Divider(height: 36, thickness: 1.2),
                      
                                             // Service Number (auto-generated for new services)
                       if (widget.service.id == 0)
                         Container(
                           padding: EdgeInsets.all(16),
                           decoration: BoxDecoration(
                             color: Colors.green.withOpacity(0.1),
                             border: Border.all(color: Colors.green),
                             borderRadius: BorderRadius.circular(8),
                           ),
                           child: Row(
                             children: [
                               Icon(Icons.confirmation_number, size: 24, color: Colors.green),
                               SizedBox(width: 12),
                               Expanded(
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Text(
                                       "Service Number (Auto-Generated):",
                                       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                                     ),
                                     SizedBox(height: 4),
                                     Text(
                                       _generateServiceNumber(),
                                       style: TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
                                     ),
                                   ],
                                 ),
                               ),
                             ],
                           ),
                         ),
                       
                       SizedBox(height: 24), // Add extra spacing between Service Number and Service Name
                       
                       // Name
                       TextFormField(
                        controller: _nameController,
                        decoration: customTextFieldDecoration(
                          "Service Name",
                          prefixIcon: Icons.miscellaneous_services,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter service name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      
                      // Description (only for existing services)
                      if (widget.service.id != 0)
                        TextFormField(
                          controller: _descriptionController,
                          decoration: customTextFieldDecoration(
                            "Description",
                            prefixIcon: Icons.description,
                          ),
                          maxLines: 3,
                        ),
                      SizedBox(height: 16),
                      
                      // Service Fee
                      TextFormField(
                        controller: _serviceFeeController,
                        decoration: customTextFieldDecoration(
                          "Service Fee (BAM)",
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter service fee';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      
                      // Estimated Duration
                      TextFormField(
                        controller: _estimatedDurationController,
                        decoration: customTextFieldDecoration(
                          "Estimated Duration (hours)",
                          prefixIcon: Icons.schedule,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16),
                      
                                             // Status
                       Container(
                         padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                         decoration: BoxDecoration(
                           border: Border.all(color: Colors.grey),
                           borderRadius: BorderRadius.circular(8),
                         ),
                         child: Row(
                           children: [
                             Icon(Icons.info_outline, color: Color(0xFF512DA8)),
                             SizedBox(width: 10),
                             Text(
                               "Status:",
                               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                             ),
                             SizedBox(width: 10),
                             Expanded(
                               child: Text(
                                 _status,
                                 style: TextStyle(fontSize: 17),
                               ),
                             ),
                           ],
                         ),
                       ),
                      SizedBox(height: 16),
                      
                                             // Customer Dropdown
                       _isLoading
                           ? Container(
                               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                               decoration: BoxDecoration(
                                 border: Border.all(color: Colors.grey),
                                 borderRadius: BorderRadius.circular(8),
                               ),
                                                               child: Row(
                                  children: [
                                    Icon(Icons.person, color: Color(0xFF512DA8)),
                                    SizedBox(width: 10),
                                    Text('Loading customers...', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                             )
                           : DropdownButtonFormField<int>(
                               value: _users.any((user) => user.id == _selectedUserId) ? _selectedUserId : null,
                               decoration: customTextFieldDecoration(
                                 "Customer",
                                 prefixIcon: Icons.person,
                               ),
                               items: _users.map((user) {
                                 return DropdownMenuItem(
                                   value: user.id,
                                   child: Text('${user.firstName} ${user.lastName}'),
                                 );
                               }).toList(),
                               onChanged: (value) {
                                 setState(() {
                                   _selectedUserId = value;
                                 });
                               },
                               validator: (value) {
                                 if (value == null) {
                                   return 'Please select a customer';
                                 }
                                 return null;
                               },
                             ),
                      SizedBox(height: 16),
                      
                      // Phone Model Dropdown with Search
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Phone Model",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                                                 TextField(
                                   controller: _phoneModelSearchController,
                                   decoration: InputDecoration(
                                     hintText: "Search phone models...",
                                     prefixIcon: Icon(Icons.phone_android, color: Color(0xFF512DA8)),
                                     border: InputBorder.none,
                                     contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                   ),
                                  onChanged: _filterPhoneModels,
                                  onTap: () {
                                    setState(() {
                                      _isPhoneModelDropdownOpen = true;
                                    });
                                  },
                                ),
                                if (_isPhoneModelDropdownOpen)
                                  Container(
                                    height: 200,
                                    child: ListView.builder(
                                      itemCount: _filteredPhoneModels.length,
                                      itemBuilder: (context, index) {
                                        final model = _filteredPhoneModels[index];
                                        return ListTile(
                                          title: Text('${model.brand} ${model.model}'),
                                          subtitle: Text(model.series ?? ''),
                                          selected: _selectedPhoneModelId == model.id,
                                          onTap: () {
                                            setState(() {
                                              _selectedPhoneModelId = model.id;
                                              _phoneModelSearchController.text = '${model.brand} ${model.model}';
                                              _isPhoneModelDropdownOpen = false;
                                            });
                                          },
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      
                      // Customer Notes
                      TextFormField(
                        controller: _customerNotesController,
                        decoration: customTextFieldDecoration(
                          "Customer Notes",
                          prefixIcon: Icons.note,
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 16),
                      
                      // Technician Notes
                      TextFormField(
                        controller: _technicianNotesController,
                        decoration: customTextFieldDecoration(
                          "Technician Notes",
                          prefixIcon: Icons.engineering,
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 24),
                      
                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _isLoading ? null : () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            ),
                            child: Text("Cancel"),
                          ),
                                                     ElevatedButton(
                             onPressed: _isLoading ? null : _saveService,
                             style: ElevatedButton.styleFrom(
                               backgroundColor: Color(0xFF512DA8),
                               foregroundColor: Colors.white,
                               padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                             ),
                             child: _isLoading
                                 ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                 : Text("Save"),
                           ),
                        ],
                      ),
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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _serviceFeeController.dispose();
    _estimatedDurationController.dispose();
    _customerNotesController.dispose();
    _technicianNotesController.dispose();
    _phoneModelSearchController.dispose();
    super.dispose();
  }
}
