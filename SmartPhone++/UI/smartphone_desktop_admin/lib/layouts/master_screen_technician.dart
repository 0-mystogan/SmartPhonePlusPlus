import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/dashboard_screen_technician.dart';
import '../screens/service_list_technician_screen.dart';
import '../screens/phone_models_list_screen.dart';
import '../screens/part_list_screen.dart';
import '../screens/part_compatibility_list_screen.dart';
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
            ListTile(
              title: Text('Dashboard'),
              leading: Icon(Icons.dashboard, color: Colors.blue),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardScreenTechnician()),
                );
              },
            ),
             ListTile(
              title: Text('Parts Compatibility'),
              leading: Icon(Icons.link, color: Colors.blue),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => PartCompatibilityListScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Phone Models'),
              leading: Icon(Icons.phone_android, color: Colors.blue),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => PhoneModelsListScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Parts'),
              leading: Icon(Icons.build, color: Colors.blue),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => PartListScreen()),
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
