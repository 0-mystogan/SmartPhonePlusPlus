import 'package:smartphone_desktop_admin/layouts/master_screen.dart';
import 'package:smartphone_desktop_admin/model/product.dart';
import 'package:smartphone_desktop_admin/model/product_image.dart';
import 'package:smartphone_desktop_admin/model/search_result.dart';
import 'package:smartphone_desktop_admin/model/category.dart';
import 'package:smartphone_desktop_admin/providers/product_provider.dart';
import 'package:smartphone_desktop_admin/providers/category_provider.dart';
import 'package:smartphone_desktop_admin/screens/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartphone_desktop_admin/utils/text_field_decoration.dart';
import 'package:smartphone_desktop_admin/utils/custom_data_table.dart';
import 'package:smartphone_desktop_admin/utils/custom_pagination.dart';
import 'dart:typed_data';
import 'dart:convert';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late ProductProvider productProvider;
  late CategoryProvider categoryProvider;
  TextEditingController searchController = TextEditingController();
  SearchResult<Product>? products;
  List<Category>? categories;
  Category? selectedCategory;
  int _currentPage = 0;
  int _pageSize = 7;
  final List<int> _pageSizeOptions = [5, 7, 10, 20, 50];
  
  // Sorting state
  String? _sortField; // 'price' or 'stock'
  bool _sortAscending = true; // true for ascending, false for descending

  Future<void> _loadCategories() async {
    try {
      setState(() {
        categories = null; // Show loading state
      });
      
      var categoriesResult = await categoryProvider.get(filter: {
        "page": 0,
        "pageSize": 100,
        "includeTotalCount": true,
      });
      setState(() {
        categories = categoriesResult?.items ?? [];
      });
      print('Loaded ${categories?.length ?? 0} categories from database');
      if (categories != null) {
        for (int i = 0; i < categories!.length; i++) {
          print('Category $i: ${categories![i].name} (ID: ${categories![i].id})');
        }
      }
    } catch (e) {
      print('Error loading categories: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading categories: $e')),
      );
    }
  }

  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;
    
    var filter = {
      "page": pageToFetch,
      "pageSize": pageSizeToUse,
      "includeTotalCount": true,
      "fts": searchController.text, // Search by name and description
    };

    // If a category is selected, use the category-specific endpoint
    if (selectedCategory != null) {
      try {
        // Use the category-specific endpoint
        var products = await productProvider.getByCategory(selectedCategory!.id, filter: filter);
        setState(() {
          this.products = products;
          _currentPage = pageToFetch;
          _pageSize = pageSizeToUse;
        });
        return;
      } catch (e) {
        print('Error using category-specific endpoint: $e');
        // Fall back to regular search if category endpoint fails
      }
    }
    
    var products = await productProvider.get(filter: filter);
    
    // Debug: Print the raw response
    print('API Response - Total Count: ${products?.totalCount}');
    print('API Response - Items Count: ${products?.items?.length ?? 0}');
    if (products?.items != null) {
      for (int i = 0; i < products!.items!.length; i++) {
        var product = products.items![i];
        print('Product $i: ${product.name}');
        print('  - ProductImages: ${product.productImages?.length ?? 0}');
        if (product.productImages != null) {
          for (int j = 0; j < product.productImages!.length; j++) {
            print('    Image $j: ${product.productImages![j].imageData?.length ?? 0} chars (Primary: ${product.productImages![j].isPrimary})');
          }
        }
      }
    }
    
    setState(() {
      this.products = products;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      productProvider = context.read<ProductProvider>();
      categoryProvider = context.read<CategoryProvider>();
      await _loadCategories();
      await _performSearch(page: 0);
    });
  }

  Future<void> _showDeleteConfirmation(Product product) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Confirm Delete'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this product?',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Product: ${product.name}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'This action cannot be undone.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteProduct(product);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProduct(Product product) async {
    try {
      setState(() {
        // Show loading state if needed
      });
      
      await productProvider.delete(product.id);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product "${product.name}" deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Refresh the list
      await _performSearch();
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting product: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _sortProducts() {
    if (_sortField == null || products?.items == null) return;
    
    List<Product> sortedProducts = List.from(products!.items!);
    
    switch (_sortField) {
      case 'price':
        sortedProducts.sort((a, b) {
          double priceA = a.currentPrice ?? a.originalPrice ?? 0.0;
          double priceB = b.currentPrice ?? b.originalPrice ?? 0.0;
          return _sortAscending ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
        });
        break;
      case 'stock':
        sortedProducts.sort((a, b) {
          return _sortAscending ? a.stockQuantity.compareTo(b.stockQuantity) : b.stockQuantity.compareTo(a.stockQuantity);
        });
        break;
    }
    
    setState(() {
      products = SearchResult<Product>(
        items: sortedProducts,
        totalCount: products!.totalCount,
      );
    });
  }

  void _toggleSort(String field) {
    setState(() {
      if (_sortField == field) {
        // If same field, toggle direction
        _sortAscending = !_sortAscending;
      } else {
        // If new field, set to ascending
        _sortField = field;
        _sortAscending = true;
      }
    });
    _sortProducts();
  }

  Color _getStockColor(int stockQuantity, int? minimumStockLevel) {
    if (minimumStockLevel == null) {
      return Colors.black; // Default color if no minimum stock level is set
    }
    
    if (stockQuantity > minimumStockLevel) {
      return Colors.lightGreen; // Stock is above minimum - light green
    } else if (stockQuantity == minimumStockLevel) {
      return Colors.orange; // Stock equals minimum - orange
    } else {
      return Colors.red; // Stock below minimum - red
    }
  }

  Widget _buildImageCell(Product product) {
    // Debug: Print product info
    print('Product: ${product.name}');
    print('ProductImages: ${product.productImages?.length ?? 0}');
    if (product.productImages != null) {
      for (int i = 0; i < product.productImages!.length; i++) {
        print('  Image $i: ${product.productImages![i].imageData?.length ?? 0} chars (Primary: ${product.productImages![i].isPrimary})');
      }
    }
    
    // Get the primary image or first image from the product
    ProductImage? primaryImage;
    
    if (product.productImages != null && product.productImages!.isNotEmpty) {
      // Try to find primary image first
      try {
        primaryImage = product.productImages!.firstWhere(
          (image) => image.isPrimary,
        );
      } catch (e) {
        // If no primary image found, use the first image
        primaryImage = product.productImages!.first;
      }
    }
    
    if (primaryImage == null || primaryImage.imageData == null || primaryImage.imageData!.isEmpty) {
      return Icon(Icons.image, size: 32, color: Colors.grey);
    }
    
    try {
      // Convert base64 string to image
      final bytes = base64Decode(primaryImage.imageData!);
      return Image.memory(
        bytes,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading image from memory: $error');
          return Icon(Icons.image, size: 32, color: Colors.grey);
        },
      );
    } catch (e) {
      print('Error converting image data: $e');
      return Icon(Icons.image, size: 32, color: Colors.grey);
    }
  }

  Widget _buildResultView() {
    final isEmpty =
        products == null || products!.items == null || products!.items!.isEmpty;
    final int totalCount = products?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage >= totalPages - 1 || totalPages == 0;
    return Column(
      children: [
                 // Active Filter Indicator
         if (selectedCategory != null || searchController.text.isNotEmpty || _sortField != null)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.filter_list, color: Colors.blue, size: 16),
                SizedBox(width: 8),
                Text(
                  'Active Filters: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                if (selectedCategory != null) ...[
                  Text(
                    'Category: ${selectedCategory!.name}',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
                if (selectedCategory != null && searchController.text.isNotEmpty)
                  Text(', ', style: TextStyle(color: Colors.blue)),
                                 if (searchController.text.isNotEmpty)
                   Text(
                     'Search: "${searchController.text}"',
                     style: TextStyle(color: Colors.blue),
                   ),
                 if ((selectedCategory != null || searchController.text.isNotEmpty) && _sortField != null)
                   Text(', ', style: TextStyle(color: Colors.blue)),
                 if (_sortField != null)
                   Text(
                     'Sort: ${_sortField == 'price' ? 'Price' : 'Stock'} ${_sortAscending ? '↑' : '↓'}',
                     style: TextStyle(color: Colors.blue),
                   ),
              ],
            ),
          ),
        CustomDataTableCard(
          width: 1300,
          height: 400,
          columns: [
            DataColumn(
              label: Text(
                "Image",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "Name",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Price",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(width: 4),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _sortField == 'price' && _sortAscending 
                            ? Icons.keyboard_arrow_up 
                            : Icons.keyboard_arrow_up,
                          size: 16,
                          color: _sortField == 'price' && _sortAscending 
                            ? Colors.blue 
                            : Colors.grey,
                        ),
                        onPressed: () => _toggleSort('price'),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(minWidth: 20, minHeight: 20),
                      ),
                      IconButton(
                        icon: Icon(
                          _sortField == 'price' && !_sortAscending 
                            ? Icons.keyboard_arrow_down 
                            : Icons.keyboard_arrow_down,
                          size: 16,
                          color: _sortField == 'price' && !_sortAscending 
                            ? Colors.blue 
                            : Colors.grey,
                        ),
                        onPressed: () => _toggleSort('price'),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(minWidth: 20, minHeight: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            DataColumn(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Stock",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(width: 4),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _sortField == 'stock' && _sortAscending 
                            ? Icons.keyboard_arrow_up 
                            : Icons.keyboard_arrow_up,
                          size: 16,
                          color: _sortField == 'stock' && _sortAscending 
                            ? Colors.blue 
                            : Colors.grey,
                        ),
                        onPressed: () => _toggleSort('stock'),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(minWidth: 20, minHeight: 20),
                      ),
                      IconButton(
                        icon: Icon(
                          _sortField == 'stock' && !_sortAscending 
                            ? Icons.keyboard_arrow_down 
                            : Icons.keyboard_arrow_down,
                          size: 16,
                          color: _sortField == 'stock' && !_sortAscending 
                            ? Colors.blue 
                            : Colors.grey,
                        ),
                        onPressed: () => _toggleSort('stock'),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(minWidth: 20, minHeight: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            DataColumn(
              label: Text(
                "Category",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "Brand",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "Status",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "Featured",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "Details",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "Actions",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
          rows: isEmpty
              ? []
              : products!.items!
                    .map(
                      (e) => DataRow(
                        cells: [
                          DataCell(_buildImageCell(e)),
                          DataCell(
                            Text(
                              e.name,
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          DataCell(
                            Text(
                              e.currentPrice != null
                                  ? '\$${e.currentPrice!.toStringAsFixed(2)}'
                                  : '\$${e.originalPrice?.toStringAsFixed(2) ?? '0.00'}',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              e.stockQuantity.toString(),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: e.stockQuantity < (e.minimumStockLevel ?? 0) ? FontWeight.bold : FontWeight.normal,
                                color: _getStockColor(e.stockQuantity, e.minimumStockLevel),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              e.categoryName ?? 'N/A',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          DataCell(
                            Text(
                              e.brand ?? 'N/A',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          DataCell(
                            Icon(
                              e.isActive ? Icons.check : Icons.close,
                              color: e.isActive ? Colors.green : Colors.red,
                            ),
                          ),
                          DataCell(
                            Icon(
                              e.isFeatured ? Icons.star : Icons.star_border,
                              color: e.isFeatured ? Colors.amber : Colors.grey,
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: Icon(Icons.info_outline),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProductDetailsScreen(product: e),
                                  ),
                                );
                                // Refresh the list when returning from product details
                                await _performSearch();
                              },
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _showDeleteConfirmation(e),
                                  tooltip: 'Delete Product',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
          emptyIcon: Icons.inventory,
          emptyText: "No products found.",
          emptySubtext: "Try adjusting your search or add a new product.",
        ),
        SizedBox(height: 10),
        CustomPagination(
          currentPage: _currentPage,
          totalPages: totalPages,
          onPrevious: isFirstPage
              ? null
              : () => _performSearch(page: _currentPage - 1),
          onNext: isLastPage
              ? null
              : () => _performSearch(page: _currentPage + 1),
          showPageSizeSelector: true,
          pageSize: _pageSize,
          pageSizeOptions: _pageSizeOptions,
          onPageSizeChanged: (newSize) {
            if (newSize != null && newSize != _pageSize) {
              _performSearch(page: 0, pageSize: newSize);
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Products",
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                                         // First row: Search and Category Filter
                     Row(
                       children: [
                         // Shortened search bar
                         Container(
                           width: 300,
                           child: TextField(
                             decoration: customTextFieldDecoration(
                               "Search by name or description...",
                               prefixIcon: Icons.search,
                             ),
                             controller: searchController,
                             onSubmitted: (value) => _performSearch(),
                           ),
                         ),
                         SizedBox(width: 10),
                         // Category Filter Dropdown
                         Container(
                           width: 200,
                           child: DropdownButtonFormField<Category>(
                             value: selectedCategory,
                             decoration: InputDecoration(
                               labelText: 'Category Filter',
                               border: OutlineInputBorder(),
                               contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                             ),
                             hint: categories == null ? Text('Loading...') : Text('All Categories'),
                             items: [
                               DropdownMenuItem<Category>(
                                 value: null,
                                 child: Text('All Categories'),
                               ),
                               ...(categories ?? []).map((category) => DropdownMenuItem<Category>(
                                 value: category,
                                 child: Text(category.name),
                               )).toList(),
                             ],
                             onChanged: categories == null ? null : (Category? newValue) {
                               setState(() {
                                 selectedCategory = newValue;
                               });
                               _performSearch(page: 0); // Reset to first page when category changes
                             },
                           ),
                         ),
                         SizedBox(width: 10),
                         ElevatedButton(
                           onPressed: _performSearch,
                           child: Text("Search"),
                         ),
                       ],
                     ),
                    SizedBox(height: 10),
                                         // Second row: Clear Filters, Clear Sort, and Add Product
                     Row(
                       children: [
                         // Clear Filters Button
                         if (selectedCategory != null || searchController.text.isNotEmpty)
                           ElevatedButton(
                             onPressed: () {
                               setState(() {
                                 selectedCategory = null;
                                 searchController.clear();
                               });
                               _performSearch(page: 0);
                             },
                             style: ElevatedButton.styleFrom(
                               backgroundColor: Colors.grey,
                               foregroundColor: Colors.white,
                             ),
                             child: Text("Clear Filters"),
                           ),
                         if (selectedCategory != null || searchController.text.isNotEmpty)
                           SizedBox(width: 10),
                         // Clear Sort Button
                         if (_sortField != null)
                           ElevatedButton(
                             onPressed: () {
                               setState(() {
                                 _sortField = null;
                                 _sortAscending = true;
                               });
                               _performSearch(page: _currentPage);
                             },
                             style: ElevatedButton.styleFrom(
                               backgroundColor: Colors.orange,
                               foregroundColor: Colors.white,
                             ),
                             child: Text("Clear Sort"),
                           ),
                         if (_sortField != null)
                           SizedBox(width: 10),
                         Spacer(),
                         ElevatedButton(
                           onPressed: () async {
                             await Navigator.push(
                               context,
                               MaterialPageRoute(builder: (context) => ProductDetailsScreen()),
                             );
                             // Refresh the list when returning from add product
                             await _performSearch();
                           },
                           style: ElevatedButton.styleFrom(
                             backgroundColor: Colors.purple,
                             foregroundColor: Colors.white,
                           ),
                           child: Text("Add Product"),
                         ),
                       ],
                     ),
                  ],
                ),
              ),
              _buildResultView(),
              SizedBox(height: 20), // Add bottom padding
            ],
          ),
        ),
      ),
    );
  }
} 