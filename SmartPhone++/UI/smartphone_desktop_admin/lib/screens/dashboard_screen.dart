import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartphone_desktop_admin/providers/auth_provider.dart';
import 'package:smartphone_desktop_admin/screens/dashboard_screen_technician.dart';
import 'package:smartphone_desktop_admin/screens/dashboard_screen_admin.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Check if user is authenticated
        if (!authProvider.isAuthenticated) {
          // Redirect to login if not authenticated
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/login');
          });
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Route based on user role
        if (authProvider.isTechnician) {
          return DashboardScreenTechnician();
        } else if (authProvider.isAdministrator) {
          return DashboardScreenAdmin();
        } else {
          // Default to technician dashboard for now
          return DashboardScreenTechnician();
        }
      },
    );
  }
} 