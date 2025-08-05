import 'package:smartphone_desktop_admin/layouts/master_screen_technician.dart';
import 'package:smartphone_desktop_admin/model/part.dart';
import 'package:smartphone_desktop_admin/model/search_result.dart';
import 'package:smartphone_desktop_admin/providers/part_provider.dart';
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
  TextEditingController nameController = TextEditingController();
  SearchResult<Part>? parts;
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
    };
    var parts = await partProvider.get(filter: filter);
    setState(() {
      this.parts = parts;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      partProvider = context.read<PartProvider>();
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
        CustomDataTableCard(
          width: 700,
          height: 400,
          columns: [
            DataColumn(
              label: Text(
                "Name",
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
                            Text(e.name, style: TextStyle(fontSize: 15)),
                          ),
                          DataCell(
                            Text(e.brand ?? 'N/A', style: TextStyle(fontSize: 15)),
                          ),
                          DataCell(
                            Text('\$${e.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 15)),
                          ),
                          DataCell(
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: e.stockQuantity < (e.minimumStockLevel ?? 5) 
                                    ? Colors.red.withOpacity(0.2) 
                                    : Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                e.stockQuantity.toString(),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: e.stockQuantity < (e.minimumStockLevel ?? 5) 
                                      ? Colors.red 
                                      : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(e.partCategoryName, style: TextStyle(fontSize: 15)),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
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
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _showDeleteConfirmation(e),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
          emptyIcon: Icons.build,
          emptyText: "No parts found.",
          emptySubtext: "Try adjusting your search or add a new part.",
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
      title: "Parts",
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
                        "Part name...",
                        prefixIcon: Icons.search,
                      ),
                      controller: nameController,
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
            ),
            Expanded(
              child: _buildResultView(),
            ),
          ],
        ),
      ),
    );
  }
}
