import 'package:smartphone_desktop_admin/layouts/master_screen_technician.dart';
import 'package:smartphone_desktop_admin/model/phone_model.dart';
import 'package:smartphone_desktop_admin/model/search_result.dart';
import 'package:smartphone_desktop_admin/providers/phone_model_provider.dart';
import 'package:smartphone_desktop_admin/screens/phone_model_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartphone_desktop_admin/utils/text_field_decoration.dart';
import 'package:smartphone_desktop_admin/utils/custom_data_table.dart';
import 'package:smartphone_desktop_admin/utils/custom_pagination.dart';

class PhoneModelsListScreen extends StatefulWidget {
  const PhoneModelsListScreen({super.key});

  @override
  State<PhoneModelsListScreen> createState() => _PhoneModelsListScreenState();
}

class _PhoneModelsListScreenState extends State<PhoneModelsListScreen> {
  late PhoneModelProvider phoneModelProvider;
  TextEditingController searchController = TextEditingController();
  SearchResult<PhoneModel>? phoneModels;
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
    var phoneModels = await phoneModelProvider.get(filter: filter);
    setState(() {
      this.phoneModels = phoneModels;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      phoneModelProvider = context.read<PhoneModelProvider>();
      await _performSearch(page: 0);
    });
  }

  Future<void> _showDeleteConfirmation(PhoneModel phoneModel) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "${phoneModel.brand} ${phoneModel.model}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deletePhoneModel(phoneModel);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePhoneModel(PhoneModel phoneModel) async {
    try {
      await phoneModelProvider.delete(phoneModel.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Phone model deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _performSearch(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting phone model: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildResultView() {
    final isEmpty =
        phoneModels == null || phoneModels!.items == null || phoneModels!.items!.isEmpty;
    final int totalCount = phoneModels?.totalCount ?? 0;
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
                "Brand",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "Model",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "Series",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "Year",
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
                "Actions",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
          rows: isEmpty
              ? []
              : phoneModels!.items!
                    .map(
                      (e) => DataRow(
                        cells: [
                          DataCell(
                            Text(e.brand, style: TextStyle(fontSize: 15)),
                          ),
                          DataCell(
                            Text(e.model, style: TextStyle(fontSize: 15)),
                          ),
                          DataCell(
                            Text(e.series ?? 'N/A', style: TextStyle(fontSize: 15)),
                          ),
                          DataCell(
                            Text(e.year ?? 'N/A', style: TextStyle(fontSize: 15)),
                          ),
                          DataCell(
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: e.isActive 
                                    ? Colors.green.withOpacity(0.2) 
                                    : Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                e.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: e.isActive ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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
                                         builder: (context) => PhoneModelDetailsScreen(phoneModel: e),
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
          emptyIcon: Icons.phone_android,
          emptyText: "No phone models found.",
          emptySubtext: "Try adjusting your search or add a new phone model.",
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
      title: "Phone Models",
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
                        "Search phone models...",
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
                          builder: (context) => PhoneModelDetailsScreen(),
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
                    child: Text("Add Phone Model"),
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
