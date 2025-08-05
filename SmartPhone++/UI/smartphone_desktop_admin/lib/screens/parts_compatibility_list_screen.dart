import 'package:smartphone_desktop_admin/layouts/master_screen_technician.dart';
import 'package:smartphone_desktop_admin/model/part_compatibility.dart';
import 'package:smartphone_desktop_admin/model/search_result.dart';
import 'package:smartphone_desktop_admin/providers/part_compatibility_provider.dart';
import 'package:smartphone_desktop_admin/screens/part_compatibility_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartphone_desktop_admin/utils/text_field_decoration.dart';
import 'package:smartphone_desktop_admin/utils/custom_data_table.dart';
import 'package:smartphone_desktop_admin/utils/custom_pagination.dart';

class PartsCompatibilityListScreen extends StatefulWidget {
  const PartsCompatibilityListScreen({super.key});

  @override
  State<PartsCompatibilityListScreen> createState() => _PartsCompatibilityListScreenState();
}

class _PartsCompatibilityListScreenState extends State<PartsCompatibilityListScreen> {
  late PartCompatibilityProvider partCompatibilityProvider;
  TextEditingController searchController = TextEditingController();
  SearchResult<PartCompatibility>? partCompatibilities;
  int _currentPage = 0;
  int _pageSize = 7;
  final List<int> _pageSizeOptions = [5, 7, 10, 20, 50];

  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;
    final searchText = searchController.text;
    var filter = {
      "page": pageToFetch,
      "pageSize": pageSizeToUse,
      "includeTotalCount": true,
      "fts": searchText,
    };
    var partCompatibilities = await partCompatibilityProvider.get(filter: filter);
    setState(() {
      this.partCompatibilities = partCompatibilities;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      partCompatibilityProvider = context.read<PartCompatibilityProvider>();
      await _performSearch(page: 0);
    });
  }

  Future<void> _showDeleteConfirmation(PartCompatibility partCompatibility) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this compatibility record? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deletePartCompatibility(partCompatibility);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePartCompatibility(PartCompatibility partCompatibility) async {
    try {
      await partCompatibilityProvider.delete(partCompatibility.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Part compatibility deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _performSearch(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting part compatibility: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildResultView() {
    final isEmpty =
        partCompatibilities == null || partCompatibilities!.items == null || partCompatibilities!.items!.isEmpty;
    final int totalCount = partCompatibilities?.totalCount ?? 0;
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
                "Part",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "Phone Model",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "Compatibility Notes",
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
              : partCompatibilities!.items!
                    .map(
                      (e) => DataRow(
                        cells: [
                          DataCell(
                            Text(e.partName ?? 'N/A', style: TextStyle(fontSize: 15)),
                          ),
                          DataCell(
                            Text(e.phoneModelName ?? 'N/A', style: TextStyle(fontSize: 15)),
                          ),
                          DataCell(
                            Text(e.compatibilityNotes ?? 'N/A', style: TextStyle(fontSize: 15)),
                          ),
                          DataCell(_buildActionsCell(e)),
                        ],
                      ),
                    )
                    .toList(),
          emptyIcon: Icons.link,
          emptyText: "No part compatibilities found.",
          emptySubtext: "Try adjusting your search or add a new compatibility record.",
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

  Widget _buildActionsCell(PartCompatibility partCompatibility) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit, color: Colors.blue),
          tooltip: 'Edit',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PartCompatibilityDetailsScreen(partCompatibility: partCompatibility),
              ),
            ).then((result) {
              if (result == true) {
                _performSearch(); // Refresh the list
              }
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          tooltip: 'Delete',
          onPressed: () => _showDeleteConfirmation(partCompatibility),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Part Compatibilities",
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
                        "Search part compatibilities...",
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
                        MaterialPageRoute(
                          builder: (context) => PartCompatibilityDetailsScreen(),
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
                    child: Text("Add Compatibility"),
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
