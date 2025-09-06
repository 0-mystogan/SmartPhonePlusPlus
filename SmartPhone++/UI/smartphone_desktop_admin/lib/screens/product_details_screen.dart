import 'dart:io';
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
  final TextEditingController _discountedPriceController =
      TextEditingController();
  final TextEditingController _stockQuantityController =
      TextEditingController();
  final TextEditingController _minimumStockLevelController =
      TextEditingController();
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

      // Generate initial SKU for new products
      if (widget.product == null) {
        _generateSKU();
      }
    });
  }

  Future<void> _loadCategories() async {
    try {
      var categoriesResult = await categoryProvider.get(
        filter: {"page": 0, "pageSize": 100, "includeTotalCount": true},
      );
      setState(() {
        categories = categoriesResult.items ?? [];
      });
    } catch (e) {
      print('Error loading categories: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading categories: $e')));
    }
  }

  void _loadProductData() {
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description ?? '';
      _priceController.text = widget.product!.currentPrice?.toString() ?? '';
      _discountedPriceController.text =
          widget.product!.originalPrice?.toString() ?? '';
      _stockQuantityController.text = widget.product!.stockQuantity.toString();
      _minimumStockLevelController.text =
          widget.product!.minimumStockLevel?.toString() ?? '';
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

      // Generate SKU if not present or empty
      if (widget.product!.sku == null || widget.product!.sku!.isEmpty) {
        _generateSKU();
      }

      // Load existing product images
      if (widget.product!.productImages != null &&
          widget.product!.productImages!.isNotEmpty) {
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

  // Generate SKU automatically based on product name and category
  void _generateSKU({bool showFeedback = false}) {
    if (_nameController.text.isNotEmpty && selectedCategory != null) {
      String productName = _nameController.text.trim();
      String categoryName = selectedCategory!.name.trim();

      // Extract first 3 characters from category name (uppercase)
      String categoryPrefix = categoryName.length >= 3
          ? categoryName.substring(0, 3).toUpperCase()
          : categoryName.toUpperCase().padRight(3, 'X');

      // Extract first 3 characters from product name (uppercase, alphanumeric only)
      String cleanProductName = productName.replaceAll(
        RegExp(r'[^a-zA-Z0-9]'),
        '',
      );
      String productPrefix;

      if (cleanProductName.isEmpty) {
        // If no alphanumeric characters, use generic prefix
        productPrefix = 'PRD';
      } else if (cleanProductName.length >= 3) {
        productPrefix = cleanProductName.substring(0, 3).toUpperCase();
      } else {
        productPrefix = cleanProductName.toUpperCase().padRight(3, 'X');
      }

      // Generate timestamp suffix (last 4 digits)
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String suffix = timestamp.substring(timestamp.length - 4);

      // Combine: CAT-PRO-XXXX
      String generatedSKU = '$categoryPrefix-$productPrefix-$suffix';

      setState(() {
        _skuController.text = generatedSKU;
      });

      // Only show feedback if explicitly requested (manual button click)
      if (showFeedback) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SKU generated: $generatedSKU'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.blue[600],
          ),
        );
      }
    } else if (showFeedback) {
      // Only show message if explicitly requested (manual button click)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter product name and select category to generate SKU',
          ),
          backgroundColor: Colors.orange[600],
        ),
      );
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
        List<File> newImages = [];
        int maxImages = 10; // Maximum 10 images per product
        int currentTotalImages = selectedImages.length + existingImages.length;

        for (var file in result.files) {
          if (currentTotalImages + newImages.length >= maxImages) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Maximum $maxImages images allowed. Some images were not added.',
                ),
                backgroundColor: Colors.orange[600],
              ),
            );
            break;
          }

          File imageFile = File(file.path!);

          // Validate file size (max 5MB per image)
          int fileSizeInBytes = await imageFile.length();
          double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

          if (fileSizeInMB > 5) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Image ${file.name} is too large. Maximum size is 5MB.',
                ),
                backgroundColor: Colors.red[600],
              ),
            );
            continue;
          }

          newImages.add(imageFile);
        }

        setState(() {
          selectedImages.addAll(newImages);
        });

        if (newImages.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${newImages.length} image(s) added successfully'),
              backgroundColor: Colors.green[600],
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking images: $e'),
          backgroundColor: Colors.red[600],
        ),
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

  // Helper method to validate form data
  String? _validateFormData() {
    // Check if at least one image is provided
    if (selectedImages.isEmpty && existingImages.isEmpty) {
      return 'Please upload at least one product image';
    }

    // Validate price vs discounted price
    if (_priceController.text.isNotEmpty &&
        _discountedPriceController.text.isNotEmpty) {
      try {
        double price = double.parse(_priceController.text);
        double discountedPrice = double.parse(_discountedPriceController.text);
        if (discountedPrice >= price) {
          return 'Discounted price must be less than original price';
        }
      } catch (e) {
        return 'Invalid price values';
      }
    }

    // Validate stock quantity vs minimum stock level
    if (_stockQuantityController.text.isNotEmpty &&
        _minimumStockLevelController.text.isNotEmpty) {
      try {
        int stockQuantity = int.parse(_stockQuantityController.text);
        int minimumStockLevel = int.parse(_minimumStockLevelController.text);
        if (minimumStockLevel > stockQuantity) {
          return 'Minimum stock level cannot be greater than current stock quantity';
        }
      } catch (e) {
        return 'Invalid stock values';
      }
    }

    return null;
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Validate category selection
      if (selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a category'),
            backgroundColor: Colors.red[600],
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Validate form data using helper method
      String? validationError = _validateFormData();
      if (validationError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validationError),
            backgroundColor: Colors.red[600],
          ),
        );
        setState(() {
          _isLoading = false;
        });
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
          if (existingImage.imageData != null &&
              existingImage.imageData!.isNotEmpty) {
            // existingImage.imageData is already a base64 string, no need to encode again
            imageBase64List.add(existingImage.imageData!);
            print('Including existing image: ${existingImage.fileName}');
          }
        }
      }

      // Prepare product request (with images included)
      final request = {
        'Name': _nameController.text,
        'Description': _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        'Price': double.parse(_priceController.text),
        'DiscountedPrice': _discountedPriceController.text.isEmpty
            ? null
            : double.parse(_discountedPriceController.text),
        'StockQuantity': int.parse(_stockQuantityController.text),
        'MinimumStockLevel': _minimumStockLevelController.text.isEmpty
            ? null
            : int.parse(_minimumStockLevelController.text),
        'SKU': _skuController.text.isEmpty ? null : _skuController.text,
        'Brand': _brandController.text.isEmpty ? null : _brandController.text,
        'Model': _modelController.text.isEmpty ? null : _modelController.text,
        'Color': _colorController.text.isEmpty ? null : _colorController.text,
        'Size': _sizeController.text.isEmpty ? null : _sizeController.text,
        'Weight': _weightController.text.isEmpty
            ? null
            : _weightController.text,
        'Dimensions': _dimensionsController.text.isEmpty
            ? null
            : _dimensionsController.text,
        'CategoryId': selectedCategory!.id,
        'IsActive': _isActive,
        'IsFeatured': _isFeatured,
        'Images':
            imageBase64List, // Add images directly to request (like user's 'picture')
      };

      if (widget.product != null) {
        // Update existing product (with images included)
        await productProvider.update(widget.product!.id, request);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product updated successfully'),
            backgroundColor: Colors.green[600],
          ),
        );
      } else {
        // Create new product (with images included)
        await productProvider.insert(request);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product created successfully'),
            backgroundColor: Colors.green[600],
          ),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
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
                        Row(
                          children: [
                            Text(
                              "Product Information",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              "* Required fields",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _nameController,
                                decoration: customTextFieldDecoration(
                                  "Product Name *",
                                ),
                                onChanged: (value) {
                                  _generateSKU(); // Auto-generate SKU when name changes
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Product name is required';
                                  }
                                  if (value.length < 3) {
                                    return 'Product name must be at least 3 characters';
                                  }
                                  if (value.length > 100) {
                                    return 'Product name must be less than 100 characters';
                                  }
                                  if (!RegExp(
                                    r'^[a-zA-Z0-9\s\-_&.,()]+$',
                                  ).hasMatch(value)) {
                                    return 'Product name contains invalid characters';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: TextFormField(
                                controller: _priceController,
                                decoration: customTextFieldDecoration(
                                  "Price *",
                                ),
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                onChanged: (value) {
                                  _calculateDiscountedPrice();
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Price is required';
                                  }
                                  double? price = double.tryParse(value);
                                  if (price == null) {
                                    return 'Please enter a valid price';
                                  }
                                  if (price <= 0) {
                                    return 'Price must be greater than 0';
                                  }
                                  if (price > 999999.99) {
                                    return 'Price must be less than 1,000,000';
                                  }
                                  if (value.contains('.') &&
                                      value.split('.')[1].length > 2) {
                                    return 'Price can have maximum 2 decimal places';
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
                          maxLength: 500,
                          validator: (value) {
                            if (value != null && value.length > 500) {
                              return 'Description must be less than 500 characters';
                            }
                            return null;
                          },
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
                                    decoration: customTextFieldDecoration(
                                      "Discounted Price (Auto: 10% off)",
                                    ),
                                    keyboardType: TextInputType.number,
                                    readOnly:
                                        true, // Make it read-only since it's auto-calculated
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Automatically calculated as 10% off the original price",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: TextFormField(
                                controller: _stockQuantityController,
                                decoration: customTextFieldDecoration(
                                  "Stock Quantity *",
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Stock quantity is required';
                                  }
                                  int? quantity = int.tryParse(value);
                                  if (quantity == null) {
                                    return 'Please enter a valid number';
                                  }
                                  if (quantity < 0) {
                                    return 'Stock quantity cannot be negative';
                                  }
                                  if (quantity > 999999) {
                                    return 'Stock quantity must be less than 1,000,000';
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
                                decoration: customTextFieldDecoration(
                                  "Minimum Stock Level (Optional)",
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    int? minLevel = int.tryParse(value);
                                    if (minLevel == null) {
                                      return 'Please enter a valid number';
                                    }
                                    if (minLevel < 0) {
                                      return 'Minimum stock level cannot be negative';
                                    }
                                    if (minLevel > 999999) {
                                      return 'Minimum stock level must be less than 1,000,000';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _skuController,
                                      decoration:
                                          customTextFieldDecoration(
                                            "SKU (Auto-generated)",
                                          ).copyWith(
                                            hintText:
                                                "Will be generated automatically",
                                            hintStyle: TextStyle(
                                              color: Colors.grey[400],
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                      readOnly: true,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () =>
                                        _generateSKU(showFeedback: true),
                                    icon: Icon(Icons.refresh),
                                    tooltip: 'Regenerate SKU',
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.blue[100],
                                      foregroundColor: Colors.blue[700],
                                    ),
                                  ),
                                ],
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
                                decoration: customTextFieldDecoration(
                                  "Brand (Optional)",
                                ),
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    if (value.length < 2) {
                                      return 'Brand must be at least 2 characters';
                                    }
                                    if (value.length > 50) {
                                      return 'Brand must be less than 50 characters';
                                    }
                                    if (!RegExp(
                                      r'^[a-zA-Z0-9\s\-&.,()]+$',
                                    ).hasMatch(value)) {
                                      return 'Brand contains invalid characters';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: TextFormField(
                                controller: _modelController,
                                decoration: customTextFieldDecoration(
                                  "Model (Optional)",
                                ),
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    if (value.length < 2) {
                                      return 'Model must be at least 2 characters';
                                    }
                                    if (value.length > 50) {
                                      return 'Model must be less than 50 characters';
                                    }
                                    if (!RegExp(
                                      r'^[a-zA-Z0-9\s\-&.,()]+$',
                                    ).hasMatch(value)) {
                                      return 'Model contains invalid characters';
                                    }
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
                                controller: _colorController,
                                decoration: customTextFieldDecoration(
                                  "Color (Optional)",
                                ),
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    if (value.length < 2) {
                                      return 'Color must be at least 2 characters';
                                    }
                                    if (value.length > 30) {
                                      return 'Color must be less than 30 characters';
                                    }
                                    if (!RegExp(
                                      r'^[a-zA-Z\s\-]+$',
                                    ).hasMatch(value)) {
                                      return 'Color can only contain letters, spaces, and hyphens';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: TextFormField(
                                controller: _sizeController,
                                decoration: customTextFieldDecoration(
                                  "Size (Optional)",
                                ),
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    if (value.length < 1) {
                                      return 'Size must be at least 1 character';
                                    }
                                    if (value.length > 20) {
                                      return 'Size must be less than 20 characters';
                                    }
                                    if (!RegExp(
                                      r'^[a-zA-Z0-9\s\-.,/]+$',
                                    ).hasMatch(value)) {
                                      return 'Size contains invalid characters';
                                    }
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
                                controller: _weightController,
                                decoration: customTextFieldDecoration(
                                  "Weight (Optional)",
                                ),
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    double? weight = double.tryParse(value);
                                    if (weight == null) {
                                      return 'Please enter a valid weight';
                                    }
                                    if (weight <= 0) {
                                      return 'Weight must be greater than 0';
                                    }
                                    if (weight > 9999.99) {
                                      return 'Weight must be less than 10,000';
                                    }
                                    if (value.contains('.') &&
                                        value.split('.')[1].length > 2) {
                                      return 'Weight can have maximum 2 decimal places';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: TextFormField(
                                controller: _dimensionsController,
                                decoration: customTextFieldDecoration(
                                  "Dimensions (Optional)",
                                ),
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    if (value.length < 3) {
                                      return 'Dimensions must be at least 3 characters';
                                    }
                                    if (value.length > 50) {
                                      return 'Dimensions must be less than 50 characters';
                                    }
                                    if (!RegExp(
                                      r'^[a-zA-Z0-9\s\-.,xX×]+$',
                                    ).hasMatch(value)) {
                                      return 'Dimensions contains invalid characters';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        DropdownButtonFormField<Category>(
                          decoration: customTextFieldDecoration("Category *"),
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
                            _generateSKU(); // Auto-generate SKU when category changes
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
                        Row(
                          children: [
                            Text(
                              "Product Images",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              "* At least 1 image required",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Maximum 10 images, 5MB per image",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
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
                            if (selectedImages.isNotEmpty ||
                                existingImages.isNotEmpty)
                              Text(
                                "${existingImages.length + selectedImages.length} image(s) total",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                          ],
                        ),
                        SizedBox(height: 10),
                        if (selectedImages.isNotEmpty ||
                            existingImages.isNotEmpty)
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
                                        image.imageData != null &&
                                                image.imageData!.isNotEmpty
                                            ? Image.memory(
                                                base64Decode(image.imageData!),
                                                width: 150,
                                                height: 150,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      print(
                                                        'Error loading image from memory: $error',
                                                      );
                                                      return Container(
                                                        width: 150,
                                                        height: 150,
                                                        color: Colors.grey[300],
                                                        child: Icon(
                                                          Icons.image,
                                                          size: 50,
                                                        ),
                                                      );
                                                    },
                                              )
                                            : Container(
                                                width: 150,
                                                height: 150,
                                                color: Colors.grey[300],
                                                child: Icon(
                                                  Icons.image,
                                                  size: 50,
                                                ),
                                              ),
                                        Positioned(
                                          top: 5,
                                          right: 5,
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.close,
                                              color: Colors.red,
                                            ),
                                            onPressed: () =>
                                                _removeExistingImage(index),
                                          ),
                                        ),
                                        // Show "Existing" badge
                                        Positioned(
                                          top: 5,
                                          left: 5,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.withOpacity(
                                                0.8,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
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
                                            icon: Icon(
                                              Icons.close,
                                              color: Colors.red,
                                            ),
                                            onPressed: () =>
                                                _removeImage(index),
                                          ),
                                        ),
                                        // Show "New" badge
                                        Positioned(
                                          top: 5,
                                          left: 5,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(
                                                0.8,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
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
                                    : Text(
                                        widget.product != null
                                            ? "Update Product"
                                            : "Create Product",
                                      ),
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.grey,
                                ),
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
