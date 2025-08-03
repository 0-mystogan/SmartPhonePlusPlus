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

class DashboardScreenAdmin extends StatefulWidget {
  const DashboardScreenAdmin({super.key});

  @override
  State<DashboardScreenAdmin> createState() => _DashboardScreenAdminState();
}

class _DashboardScreenAdminState extends State<DashboardScreenAdmin> {
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
        
        // Calculate active services
        var pendingServices = serviceResult.items?.where((s) => s.status == 'Pending').length ?? 0;
        var inProgressServices = serviceResult.items?.where((s) => s.status == 'In Progress').length ?? 0;
        var activeServices = serviceResult.items?.where((s) => s.status == 'Active').length ?? 0;
        var workingServices = serviceResult.items?.where((s) => s.status == 'Working').length ?? 0;
        var processingServices = serviceResult.items?.where((s) => s.status == 'Processing').length ?? 0;
        
        this.activeServices = pendingServices + inProgressServices + activeServices + workingServices + processingServices;
        
        // Calculate revenue
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

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Admin Dashboard",
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
                    'Administrator Dashboard - Manage your business',
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