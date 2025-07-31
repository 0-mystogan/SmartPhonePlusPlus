import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smartphone_desktop_admin/layouts/master_screen.dart';
import 'package:smartphone_desktop_admin/model/product.dart';
import 'package:smartphone_desktop_admin/model/category.dart';
import 'package:smartphone_desktop_admin/model/product_image.dart';
import 'package:smartphone_desktop_admin/providers/product_provider.dart';
import 'package:smartphone_desktop_admin/providers/category_provider.dart';
import 'package:smartphone_desktop_admin/utils/text_field_decoration.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product? product;

  const ProductDetailsScreen({super.key, this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late ProductProvider productProvider;
  late CategoryProvider categoryProvider;
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountedPriceController = TextEditingController();
  final TextEditingController _stockQuantityController = TextEditingController();
  final TextEditingController _minimumStockLevelController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _dimensionsController = TextEditingController();
  
  // Category dropdown
  List<Category> categories = [];
  Category? selectedCategory;
  
  // Image upload
  List<File> selectedImages = [];
  List<ProductImage> existingImages = []; // Load existing images from database
  
  bool _isActive = true;
  bool _isFeatured = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      productProvider = context.read<ProductProvider>();
      categoryProvider = context.read<CategoryProvider>();
      await _loadCategories();
      _loadProductData();
    });
  }

  Future<void> _loadCategories() async {
    try {
      var categoriesResult = await categoryProvider.get(filter: {
        "page": 0,
        "pageSize": 100,
        "includeTotalCount": true,
      });
      setState(() {
        categories = categoriesResult.items ?? [];
      });
    } catch (e) {
      print('Error loading categories: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading categories: $e')),
      );
    }
  }

  void _loadProductData() {
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description ?? '';
      _priceController.text = widget.product!.currentPrice?.toString() ?? '';
      _discountedPriceController.text = widget.product!.originalPrice?.toString() ?? '';
      _stockQuantityController.text = widget.product!.stockQuantity.toString();
      _minimumStockLevelController.text = widget.product!.minimumStockLevel?.toString() ?? '';
      _skuController.text = widget.product!.sku ?? '';
      _brandController.text = widget.product!.brand ?? '';
      _modelController.text = widget.product!.model ?? '';
      _colorController.text = widget.product!.color ?? '';
      _sizeController.text = widget.product!.size ?? '';
      _weightController.text = widget.product!.weight ?? '';
      _dimensionsController.text = widget.product!.dimensions ?? '';
      
      // Set selected category
      if (categories.isNotEmpty) {
        selectedCategory = categories.firstWhere(
          (cat) => cat.id == widget.product!.categoryId,
          orElse: () => categories.first,
        );
      }
      
      // Load existing product images
      if (widget.product!.productImages != null && widget.product!.productImages!.isNotEmpty) {
        existingImages = List.from(widget.product!.productImages!);
      }
      
      _isActive = widget.product!.isActive;
      _isFeatured = widget.product!.isFeatured;
    }
  }

  // Calculate discounted price (10% off)
  void _calculateDiscountedPrice() {
    if (_priceController.text.isNotEmpty) {
      try {
        double price = double.parse(_priceController.text);
        double discountedPrice = price * 0.9; // 10% off
        _discountedPriceController.text = discountedPrice.toStringAsFixed(2);
      } catch (e) {
        // If price is not a valid number, clear discounted price
        _discountedPriceController.clear();
      }
    } else {
      _discountedPriceController.clear();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountedPriceController.dispose();
    _stockQuantityController.dispose();
    _minimumStockLevelController.dispose();
    _skuController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _sizeController.dispose();
    _weightController.dispose();
    _dimensionsController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          selectedImages.addAll(result.files.map((file) => File(file.path!)).toList());
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      existingImages.removeAt(index);
    });
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a category')),
        );
        return;
      }

      // Convert selected images to base64 strings (like user image upload)
      List<String> imageBase64List = [];
      for (File imageFile in selectedImages) {
        try {
          List<int> imageBytes = await imageFile.readAsBytes();
          String base64Image = base64Encode(imageBytes);
          imageBase64List.add(base64Image);
          print('Converted image: ${imageFile.path.split('/').last} to base64');
        } catch (e) {
          print('Error converting image to base64: $e');
        }
      }

      // For updates, we need to handle existing images differently
      // The backend will replace all images, so we need to include remaining existing images
      if (widget.product != null && existingImages.isNotEmpty) {
        // Add remaining existing images to the list (they are already base64 strings)
        for (ProductImage existingImage in existingImages) {
          if (existingImage.imageData != null && existingImage.imageData!.isNotEmpty) {
            // existingImage.imageData is already a base64 string, no need to encode again
            imageBase64List.add(existingImage.imageData!);
            print('Including existing image: ${existingImage.fileName}');
          }
        }
      }

      // Prepare product request (with images included)
      final request = {
        'Name': _nameController.text,
        'Description': _descriptionController.text.isEmpty ? null : _descriptionController.text,
        'Price': double.parse(_priceController.text),
        'DiscountedPrice': _discountedPriceController.text.isEmpty ? null : double.parse(_discountedPriceController.text),
        'StockQuantity': int.parse(_stockQuantityController.text),
        'MinimumStockLevel': _minimumStockLevelController.text.isEmpty ? null : int.parse(_minimumStockLevelController.text),
        'SKU': _skuController.text.isEmpty ? null : _skuController.text,
        'Brand': _brandController.text.isEmpty ? null : _brandController.text,
        'Model': _modelController.text.isEmpty ? null : _modelController.text,
        'Color': _colorController.text.isEmpty ? null : _colorController.text,
        'Size': _sizeController.text.isEmpty ? null : _sizeController.text,
        'Weight': _weightController.text.isEmpty ? null : _weightController.text,
        'Dimensions': _dimensionsController.text.isEmpty ? null : _dimensionsController.text,
        'CategoryId': selectedCategory!.id,
        'IsActive': _isActive,
        'IsFeatured': _isFeatured,
        'Images': imageBase64List, // Add images directly to request (like user's 'picture')
      };

      if (widget.product != null) {
        // Update existing product (with images included)
        await productProvider.update(widget.product!.id, request);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product updated successfully')),
        );
      } else {
        // Create new product (with images included)
        final newProduct = await productProvider.insert(request);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product created successfully')),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Removed complex image handling methods - now using simple approach like user image upload

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: widget.product != null ? "Edit Product" : "Add Product",
      showBackButton: true,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Product Information",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _nameController,
                                decoration: customTextFieldDecoration("Product Name"),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter product name';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: TextFormField(
                                controller: _priceController,
                                decoration: customTextFieldDecoration("Price"),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  _calculateDiscountedPrice();
                                },
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
                          ],
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: customTextFieldDecoration("Description"),
                          maxLines: 3,
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    controller: _discountedPriceController,
                                    decoration: customTextFieldDecoration("Discounted Price (Auto: 10% off)"),
                                    keyboardType: TextInputType.number,
                                    readOnly: true, // Make it read-only since it's auto-calculated
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Automatically calculated as 10% off the original price",
                                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: TextFormField(
                                controller: _stockQuantityController,
                                decoration: customTextFieldDecoration("Stock Quantity"),
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
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _minimumStockLevelController,
                                decoration: customTextFieldDecoration("Minimum Stock Level (Optional)"),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: TextFormField(
                                controller: _skuController,
                                decoration: customTextFieldDecoration("SKU (Optional)"),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _brandController,
                                decoration: customTextFieldDecoration("Brand (Optional)"),
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: TextFormField(
                                controller: _modelController,
                                decoration: customTextFieldDecoration("Model (Optional)"),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _colorController,
                                decoration: customTextFieldDecoration("Color (Optional)"),
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: TextFormField(
                                controller: _sizeController,
                                decoration: customTextFieldDecoration("Size (Optional)"),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _weightController,
                                decoration: customTextFieldDecoration("Weight (Optional)"),
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: TextFormField(
                                controller: _dimensionsController,
                                decoration: customTextFieldDecoration("Dimensions (Optional)"),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        DropdownButtonFormField<Category>(
                          decoration: customTextFieldDecoration("Category"),
                          value: selectedCategory,
                          items: categories.map((Category category) {
                            return DropdownMenuItem<Category>(
                              value: category,
                              child: Text(category.name),
                            );
                          }).toList(),
                          onChanged: (Category? newValue) {
                            setState(() {
                              selectedCategory = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a category';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        // Image Upload Section
                        Text(
                          "Product Images",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pickImages,
                              icon: Icon(Icons.upload),
                              label: Text("Select Images"),
                            ),
                            SizedBox(width: 10),
                            if (selectedImages.isNotEmpty || existingImages.isNotEmpty)
                              Text(
                                "${existingImages.length + selectedImages.length} image(s) total",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                          ],
                        ),
                        SizedBox(height: 10),
                        if (selectedImages.isNotEmpty || existingImages.isNotEmpty)
                          Container(
                            height: 200,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                // Existing images from database
                                ...existingImages.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  ProductImage image = entry.value;
                                  return Container(
                                    margin: EdgeInsets.only(right: 10),
                                    child: Stack(
                                      children: [
                                        image.imageData != null && image.imageData!.isNotEmpty
                                            ? Image.memory(
                                                base64Decode(image.imageData!),
                                                width: 150,
                                                height: 150,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  print('Error loading image from memory: $error');
                                                  return Container(
                                                    width: 150,
                                                    height: 150,
                                                    color: Colors.grey[300],
                                                    child: Icon(Icons.image, size: 50),
                                                  );
                                                },
                                              )
                                            : Container(
                                                width: 150,
                                                height: 150,
                                                color: Colors.grey[300],
                                                child: Icon(Icons.image, size: 50),
                                              ),
                                        Positioned(
                                          top: 5,
                                          right: 5,
                                          child: IconButton(
                                            icon: Icon(Icons.close, color: Colors.red),
                                            onPressed: () => _removeExistingImage(index),
                                          ),
                                        ),
                                        // Show "Existing" badge
                                        Positioned(
                                          top: 5,
                                          left: 5,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.withOpacity(0.8),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'Existing',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                // New selected images
                                ...selectedImages.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  File image = entry.value;
                                  return Container(
                                    margin: EdgeInsets.only(right: 10),
                                    child: Stack(
                                      children: [
                                        Image.file(
                                          image,
                                          width: 150,
                                          height: 150,
                                          fit: BoxFit.cover,
                                        ),
                                        Positioned(
                                          top: 5,
                                          right: 5,
                                          child: IconButton(
                                            icon: Icon(Icons.close, color: Colors.red),
                                            onPressed: () => _removeImage(index),
                                          ),
                                        ),
                                        // Show "New" badge
                                        Positioned(
                                          top: 5,
                                          left: 5,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(0.8),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'New',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: CheckboxListTile(
                                title: Text("Active"),
                                value: _isActive,
                                onChanged: (value) {
                                  setState(() {
                                    _isActive = value ?? true;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: CheckboxListTile(
                                title: Text("Featured"),
                                value: _isFeatured,
                                onChanged: (value) {
                                  setState(() {
                                    _isFeatured = value ?? false;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _saveProduct,
                                child: _isLoading
                                    ? CircularProgressIndicator()
                                    : Text(widget.product != null ? "Update Product" : "Create Product"),
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(foregroundColor: Colors.grey),
                                child: Text("Cancel"),
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
      ),
    );
  }
} 