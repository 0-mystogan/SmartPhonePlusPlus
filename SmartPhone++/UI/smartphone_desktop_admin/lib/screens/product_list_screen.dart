import 'dart:convert';
import 'package:smartphone_desktop_admin/layouts/master_screen.dart';
import 'package:smartphone_desktop_admin/model/product.dart';
import 'package:smartphone_desktop_admin/model/search_result.dart';
import 'package:smartphone_desktop_admin/providers/product_provider.dart';
import 'package:smartphone_desktop_admin/screens/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartphone_desktop_admin/utils/text_field_decoration.dart';
import 'package:smartphone_desktop_admin/utils/custom_data_table.dart';
import 'package:smartphone_desktop_admin/utils/custom_pagination.dart';

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

  Widget _buildImageCell(String? imageBase64) {
    if (imageBase64 == null || imageBase64.isEmpty) {
      return Icon(Icons.image, size: 32, color: Colors.grey);
    }
    try {
      final bytes = base64Decode(imageBase64);
      return Image.memory(bytes, width: 40, height: 40, fit: BoxFit.cover);
    } catch (e) {
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
          ],
          rows: isEmpty
              ? []
              : products!.items!
                    .map(
                      (e) => DataRow(
                        cells: [
                          DataCell(_buildImageCell(null)), // TODO: Add product images
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
                                color: e.stockQuantity <= (e.minimumStockLevel ?? 0) ? Colors.red : null,
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
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProductDetailsScreen(product: e),
                                  ),
                                );
                              },
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProductDetailsScreen()),
                      );
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