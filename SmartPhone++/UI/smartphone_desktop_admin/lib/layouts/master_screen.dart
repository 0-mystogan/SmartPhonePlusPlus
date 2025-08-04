import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../screens/dashboard_screen.dart';
import '../screens/city_list_screen.dart';
import '../screens/user_list_screen.dart';
import '../screens/product_list_screen.dart';
import '../screens/service_list_screen.dart';
import '../screens/category_list_screen.dart';
import '../screens/part_category_list_screen.dart';
import 'package:smartphone_desktop_admin/main.dart';
import 'package:smartphone_desktop_admin/providers/auth_provider.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen({
    super.key,
    required this.child,
    required this.title,
    this.showBackButton = false,
  });
  final Widget child;
  final String title;
  final bool showBackButton;

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (widget.showBackButton) ...[
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              SizedBox(width: 8),
            ],
            Text(widget.title),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            // User Profile Section
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final user = authProvider.currentUser;
                return UserAccountsDrawerHeader(
                  accountName: Text(
                    user != null ? '${user.firstName} ${user.lastName}' : 'User',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  accountEmail: Text(
                    user != null ? user.email : 'user@example.com',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: user?.picture != null && user!.picture!.isNotEmpty
                        ? ClipOval(
                            child: Image.memory(
                              base64Decode(user!.picture!),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey[600],
                          ),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF512DA8),
                        Color(0xFF673AB7),
                      ],
                    ),
                  ),
                );
              },
            ),
            // Role Display
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                String roleText = 'User';
                if (authProvider.isTechnician) {
                  roleText = 'Technician';
                } else if (authProvider.isAdministrator) {
                  roleText = 'Administrator';
                }
                
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.work, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Role: $roleText',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Divider(height: 1),
            SizedBox(height: 8),
            ListTile(
              title: Text('Dashboard'),
              leading: Icon(Icons.dashboard, color: Colors.blue),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardScreen()),
                );
              },
            ),
            Divider(),
            ListTile(
              title: Text('Users'),
              leading: Icon(Icons.people, color: Colors.green),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => UserListScreen()),
                );
              },
            ),
            
            ListTile(
              title: Text('Products'),
              leading: Icon(Icons.inventory, color: Colors.orange),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ProductListScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Categories'),
              leading: Icon(Icons.category, color: Colors.purple),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => CategoryListScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Part Categories'),
              leading: Icon(Icons.build_circle, color: Colors.indigo),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => PartCategoryListScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Cities'),
              leading: Icon(Icons.location_city, color: Colors.teal),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => CityListScreen()),
                );
              },
            ),

            ListTile(
              title: Text('Services'),
              leading: Icon(Icons.build, color: Colors.blue),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ServiceListScreen()),
                );
              },
            ),
            Divider(),
            ListTile(
              title: Text('Logout'),
              leading: Icon(Icons.logout, color: Colors.red),
              onTap: () {
                // Clear authentication state
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: widget.child,
    );
  }
}
