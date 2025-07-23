import 'package:flutter/material.dart';
import '../screens/city_list_screen.dart';
import '../screens/user_list_screen.dart';
import '../screens/admin_list_screen.dart';
import '../screens/service_list_screen.dart';
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
              title: Text('Administrators'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AdminListScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Users'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => UserListScreen()),
                );
              },
            ),

            ListTile(
              title: Text('Cities'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => CityListScreen()),
                );
              },
            ),
            
            ListTile(
              title: Text('Services'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ServiceListScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Logout'),
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
