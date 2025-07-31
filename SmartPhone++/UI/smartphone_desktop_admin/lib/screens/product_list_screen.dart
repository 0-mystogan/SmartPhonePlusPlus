import 'package:smartphone_desktop_admin/layouts/master_screen.dart';
import 'package:smartphone_desktop_admin/model/product.dart';
import 'package:smartphone_desktop_admin/model/product_image.dart';
import 'package:smartphone_desktop_admin/model/search_result.dart';
import 'package:smartphone_desktop_admin/providers/product_provider.dart';
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
  TextEditingController searchController = TextEditingController();
  SearchResult<Product>? products;
  int _currentPage = 0;
  int _pageSize = 7;
  final List<int> _pageSizeOptions = [5, 7, 10, 20, 50];

  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;
    var filter = {
      "page": pageToFetch,
      "pageSize": pageSizeToUse,
      "includeTotalCount": true,
      "fts": searchController.text, // Search by name and description
    };
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
        CustomDataTableCard(
          width: 1300,
          height: 450,
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
              label: Text(
                "Price",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "Stock",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
      child: Center(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
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
                  ElevatedButton(
                    onPressed: _performSearch,
                    child: Text("Search"),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProductDetailsScreen()),
                      );
                      // Refresh the list when returning from add product
                      await _performSearch();
                    },
                    style: ElevatedButton.styleFrom(foregroundColor: Colors.lightBlue),
                    child: Text("Add Product"),
                  ),
                ],
              ),
            ),
            _buildResultView(),
          ],
        ),
      ),
    );
  }
} 