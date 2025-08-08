import 'package:smartphone_desktop_admin/layouts/master_screen_technician.dart';
import 'package:smartphone_desktop_admin/model/part_compatibility.dart';
import 'package:smartphone_desktop_admin/model/part.dart';
import 'package:smartphone_desktop_admin/model/phone_model.dart';
import 'package:smartphone_desktop_admin/model/search_result.dart';
import 'package:smartphone_desktop_admin/providers/part_compatibility_provider.dart';
import 'package:smartphone_desktop_admin/providers/part_provider.dart';
import 'package:smartphone_desktop_admin/providers/phone_model_provider.dart';
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
  late PartProvider partProvider;
  late PhoneModelProvider phoneModelProvider;
  TextEditingController searchController = TextEditingController();
  SearchResult<PartCompatibility>? partCompatibilities;
  List<Part> _parts = [];
  List<PhoneModel> _phoneModels = [];
  Part? _selectedPart;
  PhoneModel? _selectedPhoneModel;
  String? _sortBy;
  bool _sortAscending = true;
  int _currentPage = 0;
  int _pageSize = 7;
  final List<int> _pageSizeOptions = [5, 7, 10, 20, 50];
  bool _isLoading = true;

  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;
    final searchText = searchController.text;
    // Mutually exclusive filter behavior using specialized endpoints
    SearchResult<PartCompatibility> partCompatibilities;
    if (_selectedPart != null && _selectedPhoneModel == null) {
      partCompatibilities = await partCompatibilityProvider.getByPart(_selectedPart!.id);
    } else if (_selectedPhoneModel != null && _selectedPart == null) {
      partCompatibilities = await partCompatibilityProvider.getByPhoneModel(_selectedPhoneModel!.id);
    } else {
      // Fall back to paged list with optional FTS when neither is selected
      var filter = {
        "page": pageToFetch,
        "pageSize": pageSizeToUse,
        "includeTotalCount": true,
        if (searchText.isNotEmpty) "FTS": searchText,
      };
      partCompatibilities = await partCompatibilityProvider.get(filter: filter);
    }
    
    // Debug: Print the results
    print('PartCompatibilities found: ${partCompatibilities.items?.length ?? 0}');
    if (partCompatibilities.items != null) {
      for (var item in partCompatibilities.items!) {
        print('Part: ${item.partName}, Phone: ${item.phoneModelName}, Verified: ${item.isVerified}');
      }
    }
    
    setState(() {
      this.partCompatibilities = partCompatibilities;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
    
    // Apply client-side sorting if needed
    if (_sortBy != null) {
      _sortCompatibilities();
    }
  }

  Future<void> _loadParts() async {
    try {
      final result = await partProvider.get(filter: {
        "page": 0,
        "pageSize": 100,
        "includeTotalCount": true,
      });
      setState(() {
        _parts = result.items ?? [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading parts: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadPhoneModels() async {
    try {
      final result = await phoneModelProvider.get(filter: {
        "page": 0,
        "pageSize": 100,
        "includeTotalCount": true,
      });
      setState(() {
        _phoneModels = result.items ?? [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading phone models: $e'),
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
    if (partCompatibilities?.items != null) {
      _sortCompatibilities();
    }
  }

  void _sortCompatibilities() {
    if (_sortBy == null || partCompatibilities?.items == null) return;
    
    List<PartCompatibility> sortedCompatibilities = List.from(partCompatibilities!.items!);
    
    switch (_sortBy) {
      case 'partName':
        sortedCompatibilities.sort((a, b) {
          String nameA = a.partName ?? '';
          String nameB = b.partName ?? '';
          return _sortAscending ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
        });
        break;
      case 'phoneModelName':
        sortedCompatibilities.sort((a, b) {
          String nameA = a.phoneModelName ?? '';
          String nameB = b.phoneModelName ?? '';
          return _sortAscending ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
        });
        break;
      case 'isVerified':
        sortedCompatibilities.sort((a, b) {
          return _sortAscending 
              ? (a.isVerified ? 1 : 0).compareTo(b.isVerified ? 1 : 0) 
              : (b.isVerified ? 1 : 0).compareTo(a.isVerified ? 1 : 0);
        });
        break;
    }
    
    setState(() {
      partCompatibilities = SearchResult<PartCompatibility>(
        items: sortedCompatibilities,
        totalCount: partCompatibilities!.totalCount,
      );
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedPart = null;
      _selectedPhoneModel = null;
      searchController.clear();
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
      try {
        partCompatibilityProvider = context.read<PartCompatibilityProvider>();
        partProvider = context.read<PartProvider>();
        phoneModelProvider = context.read<PhoneModelProvider>();
        await _loadParts();
        await _loadPhoneModels();
        await _performSearch(page: 0);
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing screen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  Future<void> _showDeleteConfirmation(PartCompatibility partCompatibility) async {
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
                'Are you sure you want to delete this compatibility record?',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Part: ${partCompatibility.partName ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              Text(
                'Phone Model: ${partCompatibility.phoneModelName ?? 'N/A'}',
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
                await _deletePartCompatibility(partCompatibility);
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
        // Active Filter Indicator
        if (_selectedPart != null || _selectedPhoneModel != null || searchController.text.isNotEmpty || _sortBy != null)
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
                if (_selectedPart != null) ...[
                  Text(
                    'Part: ${_selectedPart!.name}',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
                if (_selectedPart != null && _selectedPhoneModel != null)
                  Text(', ', style: TextStyle(color: Colors.blue)),
                if (_selectedPhoneModel != null) ...[
                  Text(
                    'Phone: ${_selectedPhoneModel!.name}',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
                if ((_selectedPart != null || _selectedPhoneModel != null) && searchController.text.isNotEmpty)
                  Text(', ', style: TextStyle(color: Colors.blue)),
                if (searchController.text.isNotEmpty)
                  Text(
                    'Search: "${searchController.text}"',
                    style: TextStyle(color: Colors.blue),
                  ),
                if ((_selectedPart != null || _selectedPhoneModel != null || searchController.text.isNotEmpty) && _sortBy != null)
                  Text(', ', style: TextStyle(color: Colors.blue)),
                if (_sortBy != null)
                  Text(
                    'Sort: ${_sortBy == 'partName' ? 'Part' : 'Phone'} ${_sortAscending ? '↑' : '↓'}',
                    style: TextStyle(color: Colors.blue),
                  ),
              ],
            ),
          ),
        CustomDataTableCard(
          width: 1200,
          height: 400,
          columns: [
            DataColumn(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Part",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(width: 4),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _sortBy == 'partName' && _sortAscending 
                            ? Icons.keyboard_arrow_up 
                            : Icons.keyboard_arrow_up,
                          size: 16,
                          color: _sortBy == 'partName' && _sortAscending 
                            ? Colors.blue 
                            : Colors.grey,
                        ),
                        onPressed: () => _sortByColumn('partName'),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(minWidth: 20, minHeight: 20),
                      ),
                      IconButton(
                        icon: Icon(
                          _sortBy == 'partName' && !_sortAscending 
                            ? Icons.keyboard_arrow_down 
                            : Icons.keyboard_arrow_down,
                          size: 16,
                          color: _sortBy == 'partName' && !_sortAscending 
                            ? Colors.blue 
                            : Colors.grey,
                        ),
                        onPressed: () => _sortByColumn('partName'),
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
                    "Phone Model",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(width: 4),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _sortBy == 'phoneModelName' && _sortAscending 
                            ? Icons.keyboard_arrow_up 
                            : Icons.keyboard_arrow_up,
                          size: 16,
                          color: _sortBy == 'phoneModelName' && _sortAscending 
                            ? Colors.blue 
                            : Colors.grey,
                        ),
                        onPressed: () => _sortByColumn('phoneModelName'),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(minWidth: 20, minHeight: 20),
                      ),
                      IconButton(
                        icon: Icon(
                          _sortBy == 'phoneModelName' && !_sortAscending 
                            ? Icons.keyboard_arrow_down 
                            : Icons.keyboard_arrow_down,
                          size: 16,
                          color: _sortBy == 'phoneModelName' && !_sortAscending 
                            ? Colors.blue 
                            : Colors.grey,
                        ),
                        onPressed: () => _sortByColumn('phoneModelName'),
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
                            Container(
                              width: 200,
                              child: Text(
                                e.partName ?? 'N/A', 
                                style: TextStyle(fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              width: 200,
                              child: Text(
                                e.phoneModelName ?? 'N/A', 
                                style: TextStyle(fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              width: 250,
                              child: Text(
                                e.compatibilityNotes ?? 'N/A', 
                                style: TextStyle(fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(_buildActionsCell(e)),
                        ],
                      ),
                    )
                    .toList(),
          emptyIcon: Icons.link,
          emptyText: "No part compatibilities found.",
          emptySubtext: "Try adjusting your search or add a new compatibility record.",
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

  Widget _buildActionsCell(PartCompatibility partCompatibility) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit, color: Colors.blue, size: 20),
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
          icon: Icon(Icons.delete, color: Colors.red, size: 20),
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
      child: _isLoading 
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          // First row: Search and Filters
                          Row(
                            children: [
                              // Search bar
                              Container(
                                width: 300,
                                child: TextField(
                                  decoration: customTextFieldDecoration(
                                    "Search compatibilities...",
                                    prefixIcon: Icons.search,
                                  ),
                                  controller: searchController,
                                  onSubmitted: (value) => _performSearch(),
                                ),
                              ),
                              SizedBox(width: 10),
                              // Part filter dropdown
                              Container(
                                width: 200,
                                child: DropdownButtonFormField<Part>(
                                  value: _selectedPart,
                                  decoration: InputDecoration(
                                    labelText: 'Filter by Part',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  items: [
                                    DropdownMenuItem<Part>(
                                      value: null,
                                      child: Text('All Parts'),
                                    ),
                                    ..._parts.map((Part part) {
                                      return DropdownMenuItem<Part>(
                                        value: part,
                                        child: Text(part.name),
                                      );
                                    }).toList(),
                                  ],
                                  onChanged: (Part? newValue) {
                                    setState(() {
                                      _selectedPart = newValue;
                                      if (newValue != null) {
                                        _selectedPhoneModel = null;
                                      }
                                    });
                                    _performSearch(page: 0);
                                  },
                                  isExpanded: true,
                                ),
                              ),
                              SizedBox(width: 10),
                              // Phone Model filter dropdown
                              Container(
                                width: 200,
                                child: DropdownButtonFormField<PhoneModel>(
                                  value: _selectedPhoneModel,
                                  decoration: InputDecoration(
                                    labelText: 'Filter by Phone',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  items: [
                                    DropdownMenuItem<PhoneModel>(
                                      value: null,
                                      child: Text('All Phones'),
                                    ),
                                    ..._phoneModels.map((PhoneModel phone) {
                                      return DropdownMenuItem<PhoneModel>(
                                        value: phone,
                                        child: Text(phone.name),
                                      );
                                    }).toList(),
                                  ],
                                  onChanged: (PhoneModel? newValue) {
                                    setState(() {
                                      _selectedPhoneModel = newValue;
                                      if (newValue != null) {
                                        _selectedPart = null;
                                      }
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
                          // Second row: Clear Filters, Clear Sort, and Add Compatibility
                          Row(
                            children: [
                              // Clear Filters Button
                              if (_selectedPart != null || _selectedPhoneModel != null || searchController.text.isNotEmpty)
                                ElevatedButton(
                                  onPressed: _clearFilters,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text("Clear Filters"),
                                ),
                              if (_selectedPart != null || _selectedPhoneModel != null || searchController.text.isNotEmpty)
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
