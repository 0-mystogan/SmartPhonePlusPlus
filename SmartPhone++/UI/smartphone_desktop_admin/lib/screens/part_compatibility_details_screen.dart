import 'package:smartphone_desktop_admin/layouts/master_screen_technician.dart';
import 'package:smartphone_desktop_admin/model/part_compatibility.dart';
import 'package:smartphone_desktop_admin/model/part.dart';
import 'package:smartphone_desktop_admin/model/phone_model.dart';
import 'package:smartphone_desktop_admin/providers/part_compatibility_provider.dart';
import 'package:smartphone_desktop_admin/providers/part_provider.dart';
import 'package:smartphone_desktop_admin/providers/phone_model_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartphone_desktop_admin/utils/text_field_decoration.dart';

class PartCompatibilityDetailsScreen extends StatefulWidget {
  final PartCompatibility? partCompatibility;
  
  const PartCompatibilityDetailsScreen({super.key, this.partCompatibility});

  @override
  State<PartCompatibilityDetailsScreen> createState() => _PartCompatibilityDetailsScreenState();
}

class _PartCompatibilityDetailsScreenState extends State<PartCompatibilityDetailsScreen> {
  late PartCompatibilityProvider partCompatibilityProvider;
  late PartProvider partProvider;
  late PhoneModelProvider phoneModelProvider;
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  Part? _selectedPart;
  PhoneModel? _selectedPhoneModel;
  List<Part> _parts = [];
  List<PhoneModel> _phoneModels = [];
  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      partCompatibilityProvider = context.read<PartCompatibilityProvider>();
      partProvider = context.read<PartProvider>();
      phoneModelProvider = context.read<PhoneModelProvider>();
      await _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      // Load parts
      final partsResult = await partProvider.get(filter: {
        "page": 0,
        "pageSize": 100,
        "includeTotalCount": true,
      });
      
      // Load phone models
      final phoneModelsResult = await phoneModelProvider.get(filter: {
        "page": 0,
        "pageSize": 100,
        "includeTotalCount": true,
      });

      setState(() {
        _parts = partsResult.items ?? [];
        _phoneModels = phoneModelsResult.items ?? [];
      });

      // Set initial values if editing
      if (widget.partCompatibility != null) {
        _selectedPart = _parts.firstWhere(
          (part) => part.id == widget.partCompatibility!.partId,
          orElse: () => _parts.first,
        );
        _selectedPhoneModel = _phoneModels.firstWhere(
          (phone) => phone.id == widget.partCompatibility!.phoneModelId,
          orElse: () => _phoneModels.first,
        );
        _notesController.text = widget.partCompatibility!.notes ?? '';
      }

      setState(() {
        _isLoadingData = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  Future<void> _savePartCompatibility() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPart == null || _selectedPhoneModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select both a part and a phone model'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final partCompatibility = PartCompatibility(
        id: widget.partCompatibility?.id ?? 0,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        isVerified: widget.partCompatibility?.isVerified ?? false,
        createdAt: widget.partCompatibility?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        partId: _selectedPart!.id,
        phoneModelId: _selectedPhoneModel!.id,
        partName: _selectedPart!.name,
        phoneModelName: '${_selectedPhoneModel!.brand} ${_selectedPhoneModel!.model}',
      );

      if (widget.partCompatibility == null) {
        // New compatibility
        await partCompatibilityProvider.insert(partCompatibility.toJson());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Part compatibility created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Update existing compatibility
        await partCompatibilityProvider.update(partCompatibility.id, partCompatibility.toJson());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Part compatibility updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving part compatibility: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: widget.partCompatibility == null ? "Add Part Compatibility" : "Edit Part Compatibility",
      child: _isLoadingData
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Compatibility Details',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                            SizedBox(height: 20),
                            
                            // Part Selection
                            DropdownButtonFormField<Part>(
                              value: _selectedPart,
                              decoration: InputDecoration(
                                labelText: 'Part *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.build),
                              ),
                              items: _parts.map((Part part) {
                                return DropdownMenuItem<Part>(
                                  value: part,
                                  child: Text('${part.name} (${part.partCategoryName})'),
                                );
                              }).toList(),
                              onChanged: (Part? newValue) {
                                setState(() {
                                  _selectedPart = newValue;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a part';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),

                            // Phone Model Selection
                            DropdownButtonFormField<PhoneModel>(
                              value: _selectedPhoneModel,
                              decoration: InputDecoration(
                                labelText: 'Phone Model *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.phone_android),
                              ),
                              items: _phoneModels.map((PhoneModel phone) {
                                return DropdownMenuItem<PhoneModel>(
                                  value: phone,
                                  child: Text('${phone.brand} ${phone.model}'),
                                );
                              }).toList(),
                              onChanged: (PhoneModel? newValue) {
                                setState(() {
                                  _selectedPhoneModel = newValue;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a phone model';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),

                            // Notes
                            TextFormField(
                              controller: _notesController,
                              decoration: customTextFieldDecoration(
                                "Compatibility Notes (Optional)",
                                prefixIcon: Icons.note,
                              ),
                              maxLines: 3,
                              maxLength: 500,
                            ),
                            SizedBox(height: 20),

                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _savePartCompatibility,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: _isLoading
                                        ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : Text(
                                            widget.partCompatibility == null ? 'Create Compatibility' : 'Update Compatibility',
                                          ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Cancel'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 