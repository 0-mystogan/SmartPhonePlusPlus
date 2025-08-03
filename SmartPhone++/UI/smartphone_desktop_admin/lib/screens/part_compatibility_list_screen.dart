import 'package:smartphone_desktop_admin/layouts/master_screen_technician.dart';
import 'package:flutter/material.dart';

class PartCompatibilityListScreen extends StatefulWidget {
  const PartCompatibilityListScreen({super.key});

  @override
  State<PartCompatibilityListScreen> createState() => _PartCompatibilityListScreenState();
}

class _PartCompatibilityListScreenState extends State<PartCompatibilityListScreen> {
  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Parts Compatibility",
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.link,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Parts Compatibility',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This feature is not implemented yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Parts compatibility functionality not implemented yet'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              child: Text("Coming Soon"),
            ),
          ],
        ),
      ),
    );
  }
} 