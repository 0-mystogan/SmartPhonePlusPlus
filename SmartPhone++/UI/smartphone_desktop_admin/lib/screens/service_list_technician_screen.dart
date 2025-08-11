import 'package:smartphone_desktop_admin/layouts/master_screen_technician.dart';
import 'package:smartphone_desktop_admin/model/service.dart';
import 'package:smartphone_desktop_admin/model/search_result.dart';
import 'package:smartphone_desktop_admin/providers/service_provider.dart';
import 'package:smartphone_desktop_admin/screens/service_details_screen.dart';
import 'package:smartphone_desktop_admin/screens/service_details_technician_screen.dart' as technician;
import 'package:smartphone_desktop_admin/screens/service_parts_screen.dart';
import 'package:smartphone_desktop_admin/screens/invoice_viewer_screen.dart';
import 'package:provider/provider.dart';
import 'package:smartphone_desktop_admin/providers/service_part_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartphone_desktop_admin/utils/text_field_decoration.dart';
import 'package:smartphone_desktop_admin/utils/custom_data_table.dart';
import 'package:smartphone_desktop_admin/utils/custom_pagination.dart';
import 'package:smartphone_desktop_admin/providers/user_provider.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  late ServiceProvider serviceProvider;
  TextEditingController nameController = TextEditingController();
  SearchResult<Service>? services;
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
      "fts": searchText,
    };
    var services = await serviceProvider.get(filter: filter);
    setState(() {
      this.services = services;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      serviceProvider = context.read<ServiceProvider>();
      await _performSearch(page: 0);
    });
  }

  Future<void> _showDeleteConfirmation(Service service) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "${service.name}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteService(service);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteService(Service service) async {
    try {
      await serviceProvider.delete(service.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Service deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _performSearch(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting service: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildResultView() {
    final isEmpty =
        services == null || services!.items == null || services!.items!.isEmpty;
    final int totalCount = services?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage >= totalPages - 1 || totalPages == 0;
    return Column(
      children: [
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
            DataColumn(
              label: Text(
                "Details",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
          rows: isEmpty
              ? []
              : services!.items!
                    .map(
                      (e) => DataRow(
                        cells: [
                          DataCell(
                            Text(e.name, style: TextStyle(fontSize: 15)),
                          ),
                          DataCell(
                            Text(e.status, style: TextStyle(fontSize: 15)),
                          ),
                          DataCell(_buildActionsCell(e)),
                          DataCell(
                            IconButton(
                              icon: Icon(Icons.info_outline),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ServiceDetailsScreen(service: e),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
          emptyIcon: Icons.miscellaneous_services,
          emptyText: "No services found.",
          emptySubtext: "Try adjusting your search or add a new service.",
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

  Widget _buildActionsCell(Service service) {
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
                builder: (context) => technician.ServiceDetailsScreen(service: service),
              ),
            ).then((result) {
              if (result == true) {
                _performSearch(); // Refresh the list
              }
            });
          },
        ),
        if (service.status == 'Pending')
          IconButton(
            icon: Icon(Icons.check, color: Colors.green),
            tooltip: 'Complete',
            onPressed: () async {
              await serviceProvider.complete(service.id);
              await _performSearch();
            },
          ),
        IconButton(
          icon: Icon(Icons.build, color: Colors.purple),
          tooltip: 'Parts',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider<ServicePartProvider>(
                  create: (_) => ServicePartProvider(),
                  child: ServicePartsScreen(service: service),
                ),
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.receipt_long, color: Colors.orange),
          tooltip: 'Invoice',
          onPressed: () {
            if (service.status == 'Complete') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InvoiceViewerScreen(serviceId: service.id),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Only Complete services can print Invoice.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          tooltip: 'Delete',
          onPressed: () => _showDeleteConfirmation(service),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Services",
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
                        "Service name...",
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
                      // Create a default service for new service creation
                      final defaultService = Service(
                        id: 0,
                        name: '',
                        status: 'Pending',
                        createdAt: DateTime.now(),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => technician.ServiceDetailsScreen(service: defaultService),
                        ),
                      ).then((result) {
                        if (result == true) {
                          _performSearch(); // Refresh the list
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                    child: Text("Add Service"),
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
