import 'package:flutter/material.dart';
import 'package:smartphone_desktop_admin/layouts/master_screen_technician.dart';
import 'package:smartphone_desktop_admin/model/part.dart';
import 'package:smartphone_desktop_admin/model/part_category.dart';
import 'package:smartphone_desktop_admin/providers/part_provider.dart';
import 'package:smartphone_desktop_admin/providers/part_category_provider.dart';
import 'package:provider/provider.dart';

class PartDetailsScreen extends StatefulWidget {
  final Part? part;
  
  const PartDetailsScreen({super.key, this.part});

  @override
  State<PartDetailsScreen> createState() => _PartDetailsScreenState();
}

class _PartDetailsScreenState extends State<PartDetailsScreen> {
  late PartProvider partProvider;
  late PartCategoryProvider partCategoryProvider;
  bool _isLoading = false;
  bool _isLoadingCategories = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _stockQuantityController = TextEditingController();
  final _minimumStockLevelController = TextEditingController();
  final _skuController = TextEditingController();
  final _partNumberController = TextEditingController();
  
  List<PartCategory> _categories = [];
  PartCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      partProvider = context.read<PartProvider>();
      partCategoryProvider = context.read<PartCategoryProvider>();
      _loadCategories();
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

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final result = await partCategoryProvider.get();
      setState(() {
        _categories = result.items ?? [];
        // Set selected category for existing part
        if (widget.part != null) {
          _selectedCategory = _categories.firstWhere(
            (cat) => cat.id == widget.part!.partCategoryId,
            orElse: () => _categories.isNotEmpty ? _categories.first : PartCategory(createdAt: DateTime.now()),
          );
        } else if (_categories.isNotEmpty) {
          _selectedCategory = _categories.first;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading categories: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoadingCategories = false);
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
    super.dispose();
  }

  String _generateSKU() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    final namePrefix = _nameController.text.isNotEmpty 
        ? _nameController.text.substring(0, 1).toUpperCase() 
        : 'P';
    
    return 'P${namePrefix}${random}';
  }

  String _generatePartNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 999999).toString().padLeft(6, '0');
    final namePrefix = _nameController.text.isNotEmpty 
        ? _nameController.text.substring(0, 2).toUpperCase() 
        : 'PT';
    
    return 'PT-${namePrefix}-${random}';
  }

  Future<void> _savePart() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
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
        'brand': null,
        'model': null,
        'color': null,
        'condition': null,
        'grade': null,
        'isActive': true,
        'isOEM': false,
        'isCompatible': true,
        'partCategoryId': _selectedCategory!.id,
        'partCategoryName': _selectedCategory!.name,
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
                        onChanged: (value) {
                          // Update SKU and Part Number preview when name changes
                          if (widget.part == null) {
                            setState(() {
                              _skuController.text = _generateSKU();
                              _partNumberController.text = _generatePartNumber();
                            });
                          }
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
                      // Category Dropdown
                      Container(
                        width: double.infinity,
                        child: DropdownButtonFormField<PartCategory>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            labelText: 'Category *',
                            border: OutlineInputBorder(),
                          ),
                          items: _categories.map((PartCategory category) {
                            return DropdownMenuItem<PartCategory>(
                              value: category,
                              child: Text(category.name),
                            );
                          }).toList(),
                          onChanged: (PartCategory? newValue) {
                            setState(() {
                              _selectedCategory = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a category';
                            }
                            return null;
                          },
                          isExpanded: true,
                        ),
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