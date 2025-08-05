import 'package:smartphone_desktop_admin/layouts/master_screen.dart';
import 'package:smartphone_desktop_admin/model/category.dart';
import 'package:smartphone_desktop_admin/model/search_result.dart';
import 'package:smartphone_desktop_admin/providers/category_provider.dart';
import 'package:smartphone_desktop_admin/screens/category_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartphone_desktop_admin/utils/text_field_decoration.dart';
import 'package:smartphone_desktop_admin/utils/custom_data_table.dart';
import 'package:smartphone_desktop_admin/utils/custom_pagination.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  late CategoryProvider categoryProvider;

  TextEditingController nameController = TextEditingController();

  SearchResult<Category>? categories;
  int _currentPage = 0;
  int _pageSize = 7;
  final List<int> _pageSizeOptions = [5, 7, 10, 20, 50];

  // Search for categories with ENTER key, not only when button is clicked
  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;
    var filter = {
      "name": nameController.text,
      "page": pageToFetch,
      "pageSize": pageSizeToUse,
      "includeTotalCount": true, // Ensure backend returns total count
    };
    debugPrint(filter.toString());
    var categories = await categoryProvider.get(filter: filter);
    debugPrint(categories.items?.firstOrNull?.name);
    setState(() {
      this.categories = categories;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  void initState() {
    super.initState();
    // Delay to ensure context is available for Provider
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      categoryProvider = context.read<CategoryProvider>();
      await _performSearch(page: 0);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _showDeleteConfirmation(Category category) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange[600]),
              SizedBox(width: 8),
              Text('Delete Category'),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${category.name}"? This action cannot be undone.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteCategory(category);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCategory(Category category) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[600]!),
            ),
          );
        },
      );

      // Call delete API
      bool success = await categoryProvider.delete(category.id!);
      
      // Hide loading indicator
      Navigator.of(context).pop();

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category "${category.name}" deleted successfully'),
            backgroundColor: Colors.green[600],
            duration: Duration(seconds: 3),
          ),
        );
        
        // Refresh the list
        await _performSearch();
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete category. Please try again.'),
            backgroundColor: Colors.red[600],
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Hide loading indicator
      Navigator.of(context).pop();
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting category: ${e.toString()}'),
          backgroundColor: Colors.red[600],
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Categories",
      child: Center(
        child: SingleChildScrollView(
          child: Column(children: [_buildSearch(), _buildResultView()]),
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: customTextFieldDecoration(
                "Name",
                prefixIcon: Icons.search,
              ),
              controller: nameController,
              onSubmitted: (value) => _performSearch(),
            ),
          ),
          SizedBox(width: 10),
          ElevatedButton(onPressed: _performSearch, child: Text("Search")),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CategoryDetailsScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: Text("Add Category"),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final isEmpty =
        categories == null || categories!.items == null || categories!.items!.isEmpty;
    final int totalCount = categories?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage >= totalPages - 1 || totalPages == 0;
    return Column(
      children: [
        CustomDataTableCard(
          width: 800,
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
                "Description",
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
              : categories!.items!
                    .map(
                      (e) => DataRow(
                        onSelectChanged: (value) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryDetailsScreen(category: e),
                            ),
                          );
                        },
                        cells: [
                          DataCell(
                            Text(e.name, style: TextStyle(fontSize: 15)),
                          ),
                          DataCell(
                            Text(
                              e.description ?? 'No description',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: e.isActive ? Colors.green[100] : Colors.red[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                e.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: e.isActive ? Colors.green[800] : Colors.red[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Edit button (navigate to details)
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CategoryDetailsScreen(category: e),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.edit, color: Colors.blue[600]),
                                  tooltip: 'Edit Category',
                                ),
                                // Delete button
                                IconButton(
                                  onPressed: () => _showDeleteConfirmation(e),
                                  icon: Icon(Icons.delete, color: Colors.red[600]),
                                  tooltip: 'Delete Category',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
          emptyIcon: Icons.category,
          emptyText: "No categories found.",
          emptySubtext: "Try adjusting your search or add a new category.",
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
} 