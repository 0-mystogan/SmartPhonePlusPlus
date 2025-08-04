import 'package:flutter/material.dart';
import 'package:smartphone_desktop_admin/layouts/master_screen_technician.dart';
import 'package:provider/provider.dart';
import 'package:smartphone_desktop_admin/providers/service_provider.dart';
import 'package:smartphone_desktop_admin/providers/phone_model_provider.dart';
import 'package:smartphone_desktop_admin/providers/part_provider.dart';
import 'package:smartphone_desktop_admin/model/search_result.dart';
import 'package:smartphone_desktop_admin/model/service.dart';
import 'package:smartphone_desktop_admin/model/phone_model.dart';
import 'package:smartphone_desktop_admin/model/part.dart';
import 'package:smartphone_desktop_admin/screens/service_details_screen.dart';
import 'package:smartphone_desktop_admin/screens/phone_model_details_screen.dart';
import 'package:smartphone_desktop_admin/screens/part_details_screen.dart';

class DashboardScreenTechnician extends StatefulWidget {
  const DashboardScreenTechnician({super.key});

  @override
  State<DashboardScreenTechnician> createState() => _DashboardScreenTechnicianState();
}

class _DashboardScreenTechnicianState extends State<DashboardScreenTechnician> {
  late ServiceProvider serviceProvider;
  late PhoneModelProvider phoneModelProvider;
  late PartProvider partProvider;

  SearchResult<Service>? services;
  SearchResult<PhoneModel>? phoneModels;
  SearchResult<Part>? parts;

  int totalServices = 0;
  int activeServices = 0;
  int completedServices = 0;
  int totalPhoneModels = 0;
  int totalParts = 0;
  int lowStockParts = 0;
  int oemParts = 0;
  double totalServiceRevenue = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      serviceProvider = context.read<ServiceProvider>();
      phoneModelProvider = context.read<PhoneModelProvider>();
      partProvider = context.read<PartProvider>();
      await _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    try {
      // Load services
      var serviceResult = await serviceProvider.get(filter: {
        "page": 0,
        "pageSize": 1000,
        "includeTotalCount": true,
      });
      
      // Load phone models
      var phoneModelResult = await phoneModelProvider.get(filter: {
        "page": 0,
        "pageSize": 1000,
        "includeTotalCount": true,
      });
      
      // Load parts
      var partResult = await partProvider.get(filter: {
        "page": 0,
        "pageSize": 1000,
        "includeTotalCount": true,
      });

      setState(() {
        services = serviceResult;
        phoneModels = phoneModelResult;
        parts = partResult;
        
        // Calculate service statistics
        totalServices = serviceResult.totalCount ?? 0;
        
        // Calculate active services (services that are currently being worked on)
        print('=== SERVICE DEBUG INFO ===');
        print('Total services from API: ${serviceResult.items?.length ?? 0}');
        print('Service result total count: ${serviceResult.totalCount}');
        if (serviceResult.items != null) {
          for (int i = 0; i < serviceResult.items!.length; i++) {
            var service = serviceResult.items![i];
            print('Service $i: ID=${service.id}, Name="${service.name}", Status="${service.status}"');
          }
        }
        // Check for different possible status values
        var allStatuses = serviceResult.items?.map((s) => s.status).toSet() ?? <String>{};
        print('All unique status values: $allStatuses');
        
        // Try different status values that might indicate active services
        var pendingServices = serviceResult.items?.where((s) => s.status == 'Pending').length ?? 0;
        var inProgressServices = serviceResult.items?.where((s) => s.status == 'In Progress').length ?? 0;
        var activeServices = serviceResult.items?.where((s) => s.status == 'Active').length ?? 0;
        var workingServices = serviceResult.items?.where((s) => s.status == 'Working').length ?? 0;
        var processingServices = serviceResult.items?.where((s) => s.status == 'Processing').length ?? 0;
        var completedServices = serviceResult.items?.where((s) => s.status == 'Completed').length ?? 0;
        
        print('Services with "Pending": $pendingServices');
        print('Services with "In Progress": $inProgressServices');
        print('Services with "Active": $activeServices');
        print('Services with "Working": $workingServices');
        print('Services with "Processing": $processingServices');
        print('Services with "Completed": $completedServices');
        
        // Use the most likely status for active services (Pending seems to be the main one)
        this.activeServices = pendingServices + inProgressServices + activeServices + workingServices + processingServices;
        this.completedServices = completedServices;
        print('Active services count: $activeServices');
        print('=== END SERVICE DEBUG ===');
        
        // Calculate phone model statistics
        totalPhoneModels = phoneModelResult.totalCount ?? 0;
        
        // Calculate part statistics
        totalParts = partResult.totalCount ?? 0;
        
        // Calculate low stock parts
        lowStockParts = partResult.items?.where((p) => 
          p.stockQuantity < (p.minimumStockLevel ?? 5)).length ?? 0;
        
        // Calculate OEM parts
        oemParts = partResult.items?.where((p) => p.isOEM).length ?? 0;
        
        // Calculate service revenue (this would need to be calculated from service fees)
        // For now, we'll use a placeholder calculation
        totalServiceRevenue = 0.0; // This would need to be calculated from actual service data
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
    }
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      elevation: 4,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard() {
    return Card(
      elevation: 4,
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Service Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildActivityItem(
              icon: Icons.build,
              title: 'Active Services',
              subtitle: '$activeServices currently in progress',
              color: Colors.orange,
            ),
            SizedBox(height: 12),
            _buildActivityItem(
              icon: Icons.check_circle,
              title: 'Completed Services',
              subtitle: '$completedServices finished today',
              color: Colors.green,
            ),
            SizedBox(height: 12),
            _buildActivityItem(
              icon: Icons.warning,
              title: 'Low Stock Parts',
              subtitle: '$lowStockParts parts need restocking',
              color: Colors.red,
            ),
            SizedBox(height: 12),
            _buildActivityItem(
              icon: Icons.verified,
              title: 'OEM Parts',
              subtitle: '$oemParts original parts available',
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsCard() {
    return Card(
      elevation: 4,
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.build,
                    label: 'New Service',
                    color: Colors.blue,
                    onTap: () {
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
                          builder: (context) => ServiceDetailsScreen(service: defaultService),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.phone_android,
                    label: 'Add Phone Model',
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PhoneModelDetailsScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.inventory,
                    label: 'Add Part',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PartDetailsScreen()),
                      );
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.assignment,
                    label: 'View Services',
                    color: Colors.purple,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Service list screen not implemented yet'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Technician Dashboard",
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[600]!, Colors.purple[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to SmartPhone++ Technician',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Manage services, phone models, and parts efficiently',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            
            // Statistics Cards
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildStatCard(
                  title: 'Total Services',
                  value: totalServices.toString(),
                  icon: Icons.build,
                  color: Colors.blue,
                  subtitle: 'Requests',
                ),
                _buildStatCard(
                  title: 'Active Services',
                  value: activeServices.toString(),
                  icon: Icons.engineering,
                  color: Colors.orange,
                  subtitle: 'In Progress',
                ),
                _buildStatCard(
                  title: 'Phone Models',
                  value: totalPhoneModels.toString(),
                  icon: Icons.phone_android,
                  color: Colors.green,
                  subtitle: 'Available',
                ),
                _buildStatCard(
                  title: 'Total Parts',
                  value: totalParts.toString(),
                  icon: Icons.inventory,
                  color: Colors.purple,
                  subtitle: 'In Stock',
                ),
              ],
            ),
            SizedBox(height: 24),
            
            // Additional Cards Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildRecentActivityCard(),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _buildQuickActionsCard(),
                ),
              ],
            ),
            SizedBox(height: 24),
            
            // Bottom Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Low Stock Parts',
                    value: lowStockParts.toString(),
                    icon: Icons.warning,
                    color: Colors.red,
                    subtitle: 'Need Restock',
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: 'OEM Parts',
                    value: oemParts.toString(),
                    icon: Icons.verified,
                    color: Colors.amber,
                    subtitle: 'Original',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 