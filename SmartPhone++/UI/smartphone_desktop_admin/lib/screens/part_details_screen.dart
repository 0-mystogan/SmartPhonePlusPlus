import 'package:flutter/material.dart';
import 'package:smartphone_desktop_admin/layouts/master_screen_technician.dart';
import 'package:smartphone_desktop_admin/model/part.dart';
import 'package:smartphone_desktop_admin/providers/part_provider.dart';
import 'package:provider/provider.dart';

class PartDetailsScreen extends StatefulWidget {
  final Part? part;
  
  const PartDetailsScreen({super.key, this.part});

  @override
  State<PartDetailsScreen> createState() => _PartDetailsScreenState();
}

class _PartDetailsScreenState extends State<PartDetailsScreen> {
  late PartProvider partProvider;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _stockQuantityController = TextEditingController();
  final _minimumStockLevelController = TextEditingController();
  final _skuController = TextEditingController();
  final _partNumberController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();
  final _conditionController = TextEditingController();
  final _gradeController = TextEditingController();
  bool _isActive = true;
  bool _isOEM = false;
  bool _isCompatible = true;
  int _selectedCategoryId = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      partProvider = context.read<PartProvider>();
    });
    if (widget.part != null) {
      _nameController.text = widget.part!.name;
      _descriptionController.text = widget.part!.description ?? '';
      _priceController.text = widget.part!.price.toString();
      _costPriceController.text = widget.part!.costPrice?.toString() ?? '';
      _stockQuantityController.text = widget.part!.stockQuantity.toString();
      _minimumStockLevelController.text = widget.part!.minimumStockLevel?.toString() ?? '';
      _skuController.text = widget.part!.sku ?? '';
      _partNumberController.text = widget.part!.partNumber ?? '';
      _brandController.text = widget.part!.brand ?? '';
      _modelController.text = widget.part!.model ?? '';
      _colorController.text = widget.part!.color ?? '';
      _conditionController.text = widget.part!.condition ?? '';
      _gradeController.text = widget.part!.grade ?? '';
      _isActive = widget.part!.isActive;
      _isOEM = widget.part!.isOEM;
      _isCompatible = widget.part!.isCompatible;
      _selectedCategoryId = widget.part!.partCategoryId;
    } else {
      // For new parts, generate preview SKU and Part Number
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _skuController.text = _generateSKU();
            _partNumberController.text = _generatePartNumber();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _stockQuantityController.dispose();
    _minimumStockLevelController.dispose();
    _skuController.dispose();
    _partNumberController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _conditionController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  String _generateSKU() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    final brandPrefix = _brandController.text.isNotEmpty 
        ? _brandController.text.substring(0, 1).toUpperCase() 
        : 'P';
    final namePrefix = _nameController.text.isNotEmpty 
        ? _nameController.text.substring(0, 1).toUpperCase() 
        : 'A';
    
    return '${brandPrefix}${namePrefix}${random}';
  }

  String _generatePartNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 999999).toString().padLeft(6, '0');
    final brandPrefix = _brandController.text.isNotEmpty 
        ? _brandController.text.substring(0, 2).toUpperCase() 
        : 'PT';
    final namePrefix = _nameController.text.isNotEmpty 
        ? _nameController.text.substring(0, 2).toUpperCase() 
        : 'AR';
    
    return '${brandPrefix}-${namePrefix}-${random}';
  }

  Future<void> _savePart() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Generate SKU and Part Number automatically for new parts or if they are empty
      String sku = _skuController.text;
      String partNumber = _partNumberController.text;
      
      if (widget.part == null || sku.isEmpty) {
        sku = _generateSKU();
      }
      
      if (widget.part == null || partNumber.isEmpty) {
        partNumber = _generatePartNumber();
      }
      
      final partData = {
        'id': widget.part?.id ?? 0,
        'name': _nameController.text,
        'description': _descriptionController.text.isEmpty ? null : _descriptionController.text,
        'price': double.parse(_priceController.text),
        'costPrice': _costPriceController.text.isEmpty ? null : double.tryParse(_costPriceController.text),
        'stockQuantity': int.parse(_stockQuantityController.text),
        'minimumStockLevel': _minimumStockLevelController.text.isEmpty ? null : int.tryParse(_minimumStockLevelController.text),
        'sku': sku,
        'partNumber': partNumber,
        'brand': _brandController.text.isEmpty ? null : _brandController.text,
        'model': _modelController.text.isEmpty ? null : _modelController.text,
        'color': _colorController.text.isEmpty ? null : _colorController.text,
        'condition': _conditionController.text.isEmpty ? null : _conditionController.text,
        'grade': _gradeController.text.isEmpty ? null : _gradeController.text,
        'isActive': _isActive,
        'isOEM': _isOEM,
        'isCompatible': _isCompatible,
        'partCategoryId': _selectedCategoryId,
        'partCategoryName': widget.part?.partCategoryName ?? '',
        'createdAt': widget.part?.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      if (widget.part == null) {
        // New part
        await partProvider.insert(partData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Part created successfully')),
        );
      } else {
        // Update existing part
        await partProvider.update(widget.part!.id, partData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Part updated successfully')),
        );
      }
      
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving part: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: widget.part == null ? 'Add Part' : 'Edit Part',
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
                        'Part Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter part name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              decoration: InputDecoration(
                                labelText: 'Price *',
                                border: OutlineInputBorder(),
                                prefixText: '\$',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter price';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _costPriceController,
                              decoration: InputDecoration(
                                labelText: 'Cost Price',
                                border: OutlineInputBorder(),
                                prefixText: '\$',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _stockQuantityController,
                              decoration: InputDecoration(
                                labelText: 'Stock Quantity *',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter stock quantity';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _minimumStockLevelController,
                              decoration: InputDecoration(
                                labelText: 'Minimum Stock Level',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                                             Row(
                         children: [
                           Expanded(
                             child: TextFormField(
                               controller: _skuController,
                               decoration: InputDecoration(
                                 labelText: 'SKU (Auto-generated)',
                                 border: OutlineInputBorder(),
                                 filled: true,
                                 fillColor: Colors.grey[100],
                                 suffixIcon: Icon(Icons.auto_awesome, color: Colors.blue),
                               ),
                               readOnly: true,
                               enabled: false,
                             ),
                           ),
                           SizedBox(width: 16),
                                                       Expanded(
                              child: TextFormField(
                                controller: _partNumberController,
                                decoration: InputDecoration(
                                  labelText: 'Part Number (Auto-generated)',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  suffixIcon: Icon(Icons.auto_awesome, color: Colors.blue),
                                ),
                                readOnly: true,
                                enabled: false,
                              ),
                            ),
                         ],
                       ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _brandController,
                              decoration: InputDecoration(
                                labelText: 'Brand',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _modelController,
                              decoration: InputDecoration(
                                labelText: 'Model',
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
                              controller: _conditionController,
                              decoration: InputDecoration(
                                labelText: 'Condition',
                                border: OutlineInputBorder(),
                                hintText: 'New, Used, Refurbished, OEM, Aftermarket',
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _gradeController,
                        decoration: InputDecoration(
                          labelText: 'Grade',
                          border: OutlineInputBorder(),
                          hintText: 'A, B, C, D',
                        ),
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
                      SwitchListTile(
                        title: Text('OEM Part'),
                        value: _isOEM,
                        onChanged: (value) {
                          setState(() {
                            _isOEM = value;
                          });
                        },
                      ),
                      SwitchListTile(
                        title: Text('Compatible'),
                        value: _isCompatible,
                        onChanged: (value) {
                          setState(() {
                            _isCompatible = value;
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
                      onPressed: _isLoading ? null : _savePart,
                      child: _isLoading 
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text('Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF512DA8),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
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