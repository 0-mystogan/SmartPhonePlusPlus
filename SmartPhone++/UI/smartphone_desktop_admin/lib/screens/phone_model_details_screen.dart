import 'package:flutter/material.dart';
import 'package:smartphone_desktop_admin/layouts/master_screen_technician.dart';
import 'package:smartphone_desktop_admin/model/phone_model.dart';
import 'package:smartphone_desktop_admin/providers/phone_model_provider.dart';
import 'package:provider/provider.dart';

class PhoneModelDetailsScreen extends StatefulWidget {
  final PhoneModel? phoneModel;
  
  const PhoneModelDetailsScreen({super.key, this.phoneModel});

  @override
  State<PhoneModelDetailsScreen> createState() => _PhoneModelDetailsScreenState();
}

class _PhoneModelDetailsScreenState extends State<PhoneModelDetailsScreen> {
  late PhoneModelProvider phoneModelProvider;
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _seriesController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _storageController = TextEditingController();
  final _ramController = TextEditingController();
  final _networkController = TextEditingController();
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      phoneModelProvider = context.read<PhoneModelProvider>();
    });
    
    if (widget.phoneModel != null) {
      _brandController.text = widget.phoneModel!.brand;
      _modelController.text = widget.phoneModel!.model;
      _seriesController.text = widget.phoneModel!.series ?? '';
      _yearController.text = widget.phoneModel!.year ?? '';
      _colorController.text = widget.phoneModel!.color ?? '';
      _storageController.text = widget.phoneModel!.storage ?? '';
      _ramController.text = widget.phoneModel!.ram ?? '';
      _networkController.text = widget.phoneModel!.network ?? '';
      _isActive = widget.phoneModel!.isActive;
    }
  }

  Future<void> _savePhoneModel() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final phoneModel = PhoneModel(
        id: widget.phoneModel?.id ?? 0,
        brand: _brandController.text,
        model: _modelController.text,
        series: _seriesController.text.isEmpty ? null : _seriesController.text,
        year: _yearController.text.isEmpty ? null : _yearController.text,
        color: _colorController.text.isEmpty ? null : _colorController.text,
        storage: _storageController.text.isEmpty ? null : _storageController.text,
        ram: _ramController.text.isEmpty ? null : _ramController.text,
        network: _networkController.text.isEmpty ? null : _networkController.text,
        imageUrl: widget.phoneModel?.imageUrl,
        isActive: _isActive,
        createdAt: widget.phoneModel?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      if (widget.phoneModel == null) {
        // New phone model
        await phoneModelProvider.insert(phoneModel.toJson());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Phone model created successfully')),
        );
      } else {
        // Update existing phone model
        await phoneModelProvider.update(phoneModel.id, phoneModel.toJson());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Phone model updated successfully')),
        );
      }
      
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving phone model: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _seriesController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _storageController.dispose();
    _ramController.dispose();
    _networkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: widget.phoneModel == null ? 'Add Phone Model' : 'Edit Phone Model',
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phone Model Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _brandController,
                              decoration: InputDecoration(
                                labelText: 'Brand *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter brand';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _modelController,
                              decoration: InputDecoration(
                                labelText: 'Model *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter model';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _seriesController,
                              decoration: InputDecoration(
                                labelText: 'Series',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _yearController,
                              decoration: InputDecoration(
                                labelText: 'Year',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _colorController,
                              decoration: InputDecoration(
                                labelText: 'Color',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _storageController,
                              decoration: InputDecoration(
                                labelText: 'Storage',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _ramController,
                              decoration: InputDecoration(
                                labelText: 'RAM',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _networkController,
                              decoration: InputDecoration(
                                labelText: 'Network',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      SwitchListTile(
                        title: Text('Active'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                                        Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _savePhoneModel,
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              : Text('Save'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Color(0xFF512DA8),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                  SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
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
} 