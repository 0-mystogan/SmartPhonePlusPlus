import 'package:flutter/material.dart';
import 'package:smartphone_desktop_admin/layouts/master_screen.dart';
import 'package:provider/provider.dart';
import 'package:smartphone_desktop_admin/providers/product_provider.dart';
import 'package:smartphone_desktop_admin/providers/service_provider.dart';
import 'package:smartphone_desktop_admin/providers/user_provider.dart';
import 'package:smartphone_desktop_admin/model/search_result.dart';
import 'package:smartphone_desktop_admin/model/product.dart';
import 'package:smartphone_desktop_admin/model/service.dart';
import 'package:smartphone_desktop_admin/model/user.dart';
import 'package:smartphone_desktop_admin/screens/product_details_screen.dart';
import 'package:smartphone_desktop_admin/screens/category_details_screen.dart';
import 'package:smartphone_desktop_admin/screens/user_details_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late ProductProvider productProvider;
  late ServiceProvider serviceProvider;
  late UserProvider userProvider;

  SearchResult<Product>? products;
  SearchResult<Service>? services;
  SearchResult<User>? users;

  int totalProducts = 0;
  int activeServices = 0;
  int totalUsers = 0;
  double totalRevenue = 0.0;
  int lowStockProducts = 0;
  int featuredProducts = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      productProvider = context.read<ProductProvider>();
      serviceProvider = context.read<ServiceProvider>();
      userProvider = context.read<UserProvider>();
      await _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    try {
      // Load products
      var productResult = await productProvider.get(filter: {
        "page": 0,
        "pageSize": 1000,
        "includeTotalCount": true,
      });
      
      // Load services
      var serviceResult = await serviceProvider.get(filter: {
        "page": 0,
        "pageSize": 1000,
        "includeTotalCount": true,
      });
      
      // Load users
      var userResult = await userProvider.get(filter: {
        "page": 0,
        "pageSize": 1000,
        "includeTotalCount": true,
      });

      setState(() {
        products = productResult;
        services = serviceResult;
        users = userResult;
        
        // Calculate statistics
        totalProducts = productResult.totalCount ?? 0;
        totalUsers = userResult.totalCount ?? 0;
        
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
        
        print('Services with "Pending": $pendingServices');
        print('Services with "In Progress": $inProgressServices');
        print('Services with "Active": $activeServices');
        print('Services with "Working": $workingServices');
        print('Services with "Processing": $processingServices');
        
        // Use the most likely status for active services (Pending seems to be the main one)
        this.activeServices = pendingServices + inProgressServices + activeServices + workingServices + processingServices;
        print('Active services count: $activeServices');
        print('=== END SERVICE DEBUG ===');
        
        // Calculate revenue (sum of all product prices)
        if (productResult.items != null) {
          totalRevenue = productResult.items!.fold(0.0, (sum, product) {
            double price = product.currentPrice ?? product.originalPrice ?? 0.0;
            return sum + price;
          });
        } else {
          totalRevenue = 0.0;
        }
        
        // Calculate low stock products
        lowStockProducts = productResult.items?.where((p) => 
          p.stockQuantity < (p.minimumStockLevel ?? 5)).length ?? 0;
        
        // Calculate featured products
        featuredProducts = productResult.items?.where((p) => p.isFeatured).length ?? 0;
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
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildActivityItem(
              icon: Icons.inventory,
              title: 'Products in Stock',
              subtitle: '$totalProducts items available',
              color: Colors.green,
            ),
            SizedBox(height: 12),
            _buildActivityItem(
              icon: Icons.build,
              title: 'Active Services',
              subtitle: '$activeServices currently in progress',
              color: Colors.orange,
            ),
            SizedBox(height: 12),
            _buildActivityItem(
              icon: Icons.warning,
              title: 'Low Stock Alert',
              subtitle: '$lowStockProducts products need restocking',
              color: Colors.red,
            ),
            SizedBox(height: 12),
            _buildActivityItem(
              icon: Icons.star,
              title: 'Featured Products',
              subtitle: '$featuredProducts highlighted items',
              color: Colors.amber,
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
                    icon: Icons.add,
                    label: 'Add Product',
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProductDetailsScreen()),
                      );
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.build,
                    label: 'New Service',
                    color: Colors.blue,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Service creation not implemented yet'),
                          backgroundColor: Colors.orange,
                        ),
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
                    icon: Icons.category,
                    label: 'Add Category',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CategoryDetailsScreen()),
                      );
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.person_add,
                    label: 'Add User',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UserDetailsScreen()),
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
      title: "Dashboard",
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
                    'Welcome to SmartPhone++ Admin',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Track your sales, services, and inventory at a glance',
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
                  title: 'Total Products',
                  value: totalProducts.toString(),
                  icon: Icons.inventory,
                  color: Colors.blue,
                  subtitle: 'Items',
                ),
                _buildStatCard(
                  title: 'Active Services',
                  value: activeServices.toString(),
                  icon: Icons.build,
                  color: Colors.orange,
                  subtitle: 'In Progress',
                ),
                _buildStatCard(
                  title: 'Total Users',
                  value: totalUsers.toString(),
                  icon: Icons.people,
                  color: Colors.green,
                  subtitle: 'Registered',
                ),
                _buildStatCard(
                  title: 'Total Revenue',
                  value: '\$${totalRevenue.toStringAsFixed(2)}',
                  icon: Icons.attach_money,
                  color: Colors.purple,
                  subtitle: 'Generated',
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
                    title: 'Low Stock Products',
                    value: lowStockProducts.toString(),
                    icon: Icons.warning,
                    color: Colors.red,
                    subtitle: 'Need Restock',
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: 'Featured Products',
                    value: featuredProducts.toString(),
                    icon: Icons.star,
                    color: Colors.amber,
                    subtitle: 'Highlighted',
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