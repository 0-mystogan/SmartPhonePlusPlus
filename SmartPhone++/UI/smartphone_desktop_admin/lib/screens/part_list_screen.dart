import 'package:smartphone_desktop_admin/layouts/master_screen_technician.dart';
import 'package:smartphone_desktop_admin/model/part.dart';
import 'package:smartphone_desktop_admin/model/part_category.dart';
import 'package:smartphone_desktop_admin/model/search_result.dart';
import 'package:smartphone_desktop_admin/providers/part_provider.dart';
import 'package:smartphone_desktop_admin/providers/part_category_provider.dart';
import 'package:smartphone_desktop_admin/screens/part_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartphone_desktop_admin/utils/text_field_decoration.dart';
import 'package:smartphone_desktop_admin/utils/custom_data_table.dart';
import 'package:smartphone_desktop_admin/utils/custom_pagination.dart';

class PartListScreen extends StatefulWidget {
  const PartListScreen({super.key});

  @override
  State<PartListScreen> createState() => _PartListScreenState();
}

class _PartListScreenState extends State<PartListScreen> {
  late PartProvider partProvider;
  late PartCategoryProvider partCategoryProvider;
  TextEditingController nameController = TextEditingController();
  SearchResult<Part>? parts;
  List<PartCategory> _categories = [];
  PartCategory? _selectedCategory;
  String? _sortBy;
  bool _sortAscending = true;
  int _currentPage = 0;
  int _pageSize = 7;
  final List<int> _pageSizeOptions = [5, 7, 10, 20, 50];

  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;
    final searchText = nameController.text;
    var filter = {
      "page": pageToFetch,
      "pageSize": pageSizeToUse,
      "includeTotalCount": true,
      "name": searchText,
      if (_selectedCategory != null) "partCategoryId": _selectedCategory!.id,
    };
    var parts = await partProvider.get(filter: filter);
    setState(() {
      this.parts = parts;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
    
    // Apply client-side sorting if needed
    if (_sortBy != null) {
      _sortProducts();
    }
  }

  Future<void> _loadCategories() async {
    try {
      final result = await partCategoryProvider.get();
      setState(() {
        _categories = result.items ?? [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading categories: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _sortByColumn(String column) {
    setState(() {
      if (_sortBy == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortBy = column;
        _sortAscending = true;
      }
    });
    
    // If we have data, sort immediately; otherwise, it will be sorted after the next search
    if (parts?.items != null) {
      _sortProducts();
    }
  }

  void _sortProducts() {
    if (_sortBy == null || parts?.items == null) return;
    
    List<Part> sortedParts = List.from(parts!.items!);
    
    switch (_sortBy) {
      case 'price':
        sortedParts.sort((a, b) {
          return _sortAscending ? a.price.compareTo(b.price) : b.price.compareTo(a.price);
        });
        break;
      case 'stockQuantity':
        sortedParts.sort((a, b) {
          return _sortAscending ? a.stockQuantity.compareTo(b.stockQuantity) : b.stockQuantity.compareTo(a.stockQuantity);
        });
        break;
    }
    
    setState(() {
      parts = SearchResult<Part>(
        items: sortedParts,
        totalCount: parts!.totalCount,
      );
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      nameController.clear();
    });
    _performSearch(page: 0);
  }

  void _clearSort() {
    setState(() {
      _sortBy = null;
      _sortAscending = true;
    });
    _performSearch(page: _currentPage);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      partProvider = context.read<PartProvider>();
      partCategoryProvider = context.read<PartCategoryProvider>();
      await _loadCategories();
      await _performSearch(page: 0);
    });
  }

  Future<void> _showDeleteConfirmation(Part part) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "${part.name}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deletePart(part);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePart(Part part) async {
    try {
      await partProvider.delete(part.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Part deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _performSearch(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting part: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildResultView() {
    final isEmpty =
        parts == null || parts!.items == null || parts!.items!.isEmpty;
    final int totalCount = parts?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage >= totalPages - 1 || totalPages == 0;
    return Column(
      children: [
        // Active Filter Indicator
        if (_selectedCategory != null || nameController.text.isNotEmpty || _sortBy != null)
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
                if (_selectedCategory != null) ...[
                  Text(
                    'Category: ${_selectedCategory!.name}',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
                if (_selectedCategory != null && nameController.text.isNotEmpty)
                  Text(', ', style: TextStyle(color: Colors.blue)),
                if (nameController.text.isNotEmpty)
                  Text(
                    'Search: "${nameController.text}"',
                    style: TextStyle(color: Colors.blue),
                  ),
                if ((_selectedCategory != null || nameController.text.isNotEmpty) && _sortBy != null)
                  Text(', ', style: TextStyle(color: Colors.blue)),
                if (_sortBy != null)
                  Text(
                    'Sort: ${_sortBy == 'price' ? 'Price' : 'Stock'} ${_sortAscending ? '↑' : '↓'}',
                    style: TextStyle(color: Colors.blue),
                  ),
              ],
            ),
          ),
        CustomDataTableCard(
          width: 900,
          height: 400,
          columns: [
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
                          _sortBy == 'price' && _sortAscending 
                            ? Icons.keyboard_arrow_up 
                            : Icons.keyboard_arrow_up,
                          size: 16,
                          color: _sortBy == 'price' && _sortAscending 
                            ? Colors.blue 
                            : Colors.grey,
                        ),
                        onPressed: () => _sortByColumn('price'),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(minWidth: 20, minHeight: 20),
                      ),
                      IconButton(
                        icon: Icon(
                          _sortBy == 'price' && !_sortAscending 
                            ? Icons.keyboard_arrow_down 
                            : Icons.keyboard_arrow_down,
                          size: 16,
                          color: _sortBy == 'price' && !_sortAscending 
                            ? Colors.blue 
                            : Colors.grey,
                        ),
                        onPressed: () => _sortByColumn('price'),
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
                    "Stock Level",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(width: 4),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _sortBy == 'stockQuantity' && _sortAscending 
                            ? Icons.keyboard_arrow_up 
                            : Icons.keyboard_arrow_up,
                          size: 16,
                          color: _sortBy == 'stockQuantity' && _sortAscending 
                            ? Colors.blue 
                            : Colors.grey,
                        ),
                        onPressed: () => _sortByColumn('stockQuantity'),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(minWidth: 20, minHeight: 20),
                      ),
                      IconButton(
                        icon: Icon(
                          _sortBy == 'stockQuantity' && !_sortAscending 
                            ? Icons.keyboard_arrow_down 
                            : Icons.keyboard_arrow_down,
                          size: 16,
                          color: _sortBy == 'stockQuantity' && !_sortAscending 
                            ? Colors.blue 
                            : Colors.grey,
                        ),
                        onPressed: () => _sortByColumn('stockQuantity'),
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
                "Actions",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
          rows: isEmpty
              ? []
              : parts!.items!
                    .map(
                      (e) => DataRow(
                        cells: [
                          DataCell(
                            Container(
                              width: 200,
                              child: Text(
                                e.name, 
                                style: TextStyle(fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(
                            Text('BAM ${e.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 15)),
                          ),
                          DataCell(
                            e.stockQuantity == (e.minimumStockLevel ?? 5)
                                ? Text(
                                    e.stockQuantity.toString(),
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.lightGreen.shade700,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  )
                                : Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStockLevelColor(e.stockQuantity, e.minimumStockLevel ?? 5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      e.stockQuantity.toString(),
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: _getStockLevelTextColor(e.stockQuantity, e.minimumStockLevel ?? 5),
                                        fontWeight: e.stockQuantity < (e.minimumStockLevel ?? 5) 
                                            ? FontWeight.bold 
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                          ),
                          DataCell(
                            Container(
                              width: 150,
                              child: Text(
                                e.partCategoryName, 
                                style: TextStyle(fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              width: 100,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue, size: 20),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PartDetailsScreen(part: e),
                                        ),
                                      ).then((result) {
                                        if (result == true) {
                                          _performSearch();
                                        }
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red, size: 20),
                                    onPressed: () => _showDeleteConfirmation(e),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
          emptyIcon: Icons.build,
          emptyText: "No parts found.",
          emptySubtext: "Try adjusting your search or add a new part.",
          columnSpacing: 32,
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

  Color _getStockLevelColor(int stockQuantity, int minimumStockLevel) {
    if (stockQuantity > minimumStockLevel) {
      return Colors.green.withOpacity(0.2); // Green bubble for above minimum
    } else if (stockQuantity == minimumStockLevel) {
      return Colors.lightGreen.withOpacity(0.2); // Light green for equal to minimum
    } else {
      return Colors.red.withOpacity(0.2); // Red for below minimum
    }
  }

  Color _getStockLevelTextColor(int stockQuantity, int minimumStockLevel) {
    if (stockQuantity > minimumStockLevel) {
      return Colors.green; // Green text for above minimum
    } else if (stockQuantity == minimumStockLevel) {
      return Colors.lightGreen.shade700; // Light green text for equal to minimum
    } else {
      return Colors.red; // Red text for below minimum
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Parts",
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
                              "Part name...",
                              prefixIcon: Icons.search,
                            ),
                            controller: nameController,
                            onSubmitted: (value) => _performSearch(),
                          ),
                        ),
                        SizedBox(width: 10),
                        // Category filter dropdown
                        Container(
                          width: 200,
                          child: DropdownButtonFormField<PartCategory>(
                            value: _selectedCategory,
                            decoration: InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: [
                              DropdownMenuItem<PartCategory>(
                                value: null,
                                child: Text('All Categories'),
                              ),
                              ..._categories.map((PartCategory category) {
                                return DropdownMenuItem<PartCategory>(
                                  value: category,
                                  child: Text(category.name),
                                );
                              }).toList(),
                            ],
                            onChanged: (PartCategory? newValue) {
                              setState(() {
                                _selectedCategory = newValue;
                              });
                              _performSearch(page: 0);
                            },
                            isExpanded: true,
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
                    // Second row: Clear Filters, Clear Sort, and Add Part
                    Row(
                      children: [
                        // Clear Filters Button
                        if (_selectedCategory != null || nameController.text.isNotEmpty)
                          ElevatedButton(
                            onPressed: _clearFilters,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                            ),
                            child: Text("Clear Filters"),
                          ),
                        if (_selectedCategory != null || nameController.text.isNotEmpty)
                          SizedBox(width: 10),
                        // Clear Sort Button
                        if (_sortBy != null)
                          ElevatedButton(
                            onPressed: _clearSort,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            child: Text("Clear Sort"),
                          ),
                        if (_sortBy != null)
                          SizedBox(width: 10),
                        Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PartDetailsScreen(),
                              ),
                            ).then((result) {
                              if (result == true) {
                                _performSearch();
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                          ),
                          child: Text("Add Part"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildResultView(),
            ],
          ),
        ),
      ),
    );
  }
}
