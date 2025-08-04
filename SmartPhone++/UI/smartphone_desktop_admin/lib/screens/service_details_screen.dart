import 'package:smartphone_desktop_admin/layouts/master_screen.dart';
import 'package:smartphone_desktop_admin/model/service.dart';
import 'package:flutter/material.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final Service service;
  const ServiceDetailsScreen({super.key, required this.service});

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 22, color: Colors.orange),
            SizedBox(width: 10),
          ],
          Text(
            "$label:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 17),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowWithNull(String label, String? value, {IconData? icon}) {
    return _buildInfoRow(label, value ?? 'Not specified', icon: icon);
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Not specified';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Service Details",
      showBackButton: true,
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 36.0,
                  vertical: 36.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      service.name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800],
                      ),
                    ),
                    SizedBox(height: 24),
                    Divider(height: 36, thickness: 1.2),
                    _buildInfoRow(
                      "ID",
                      service.id.toString(),
                      icon: Icons.confirmation_number,
                    ),
                    _buildInfoRow(
                      "Name",
                      service.name,
                      icon: Icons.miscellaneous_services,
                    ),
                    _buildInfoRowWithNull(
                      "Description",
                      service.description,
                      icon: Icons.description,
                    ),
                    _buildInfoRow(
                      "Service Fee",
                      "\$${service.serviceFee.toStringAsFixed(2)}",
                      icon: Icons.attach_money,
                    ),
                    _buildInfoRowWithNull(
                      "Estimated Duration",
                      service.estimatedDuration != null 
                          ? "${service.estimatedDuration} hours"
                          : null,
                      icon: Icons.schedule,
                    ),
                    _buildInfoRow(
                      "Status",
                      service.status,
                      icon: Icons.info_outline,
                    ),
                    _buildInfoRowWithNull(
                      "Customer Notes",
                      service.customerNotes,
                      icon: Icons.note,
                    ),
                    _buildInfoRowWithNull(
                      "Technician Notes",
                      service.technicianNotes,
                      icon: Icons.engineering,
                    ),
                    _buildInfoRow(
                      "Created At",
                      _formatDateTime(service.createdAt),
                      icon: Icons.create,
                    ),
                    _buildInfoRowWithNull(
                      "Updated At",
                      service.updatedAt != null ? _formatDateTime(service.updatedAt) : null,
                      icon: Icons.update,
                    ),
                    _buildInfoRowWithNull(
                      "Started At",
                      service.startedAt != null ? _formatDateTime(service.startedAt) : null,
                      icon: Icons.play_arrow,
                    ),
                    _buildInfoRowWithNull(
                      "Completed At",
                      service.completedAt != null ? _formatDateTime(service.completedAt) : null,
                      icon: Icons.check_circle,
                    ),
                    _buildInfoRow(
                      "Customer ID",
                      service.userId.toString(),
                      icon: Icons.person,
                    ),
                    _buildInfoRowWithNull(
                      "Technician ID",
                      service.technicianId?.toString(),
                      icon: Icons.engineering,
                    ),
                    _buildInfoRowWithNull(
                      "Phone Model ID",
                      service.phoneModelId?.toString(),
                      icon: Icons.phone_android,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
