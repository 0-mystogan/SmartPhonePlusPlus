import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/city_list_screen.dart';
import '../screens/user_list_screen.dart';
import '../screens/product_list_screen.dart';
import '../screens/service_list_screen.dart';
import '../screens/category_list_screen.dart';
import '../screens/part_category_list_screen.dart';
import 'package:smartphone_desktop_admin/main.dart';

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
