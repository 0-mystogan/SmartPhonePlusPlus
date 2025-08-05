import 'package:smartphone_desktop_admin/layouts/master_screen.dart';
import 'package:smartphone_desktop_admin/model/service.dart';
import 'package:smartphone_desktop_admin/model/user.dart';
import 'package:smartphone_desktop_admin/model/phone_model.dart';
import 'package:smartphone_desktop_admin/providers/user_provider.dart';
import 'package:smartphone_desktop_admin/providers/phone_model_provider.dart';
import 'package:flutter/material.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final Service service;
  const ServiceDetailsScreen({super.key, required this.service});

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  User? customer;
  User? technician;
  PhoneModel? phoneModel;
  bool isLoading = true;
  String? errorMessage;

  final UserProvider _userProvider = UserProvider();
  final PhoneModelProvider _phoneModelProvider = PhoneModelProvider();

  @override
  void initState() {
    super.initState();
    _loadRelatedData();
  }

  Future<void> _loadRelatedData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Load customer data
      if (widget.service.userId > 0) {
        customer = await _userProvider.getById(widget.service.userId);
      }

      // Load technician data
      if (widget.service.technicianId != null && widget.service.technicianId! > 0) {
        technician = await _userProvider.getById(widget.service.technicianId!);
      }

      // Load phone model data
      if (widget.service.phoneModelId != null && widget.service.phoneModelId! > 0) {
        phoneModel = await _phoneModelProvider.getById(widget.service.phoneModelId!);
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Failed to load related data: $e";
      });
    }
  }

  String _getCustomerName() {
    if (customer == null) return "Loading...";
    return "${customer!.firstName} ${customer!.lastName}";
  }

  String _getTechnicianName() {
    if (technician == null) return "Loading...";
    return "${technician!.firstName} ${technician!.lastName}";
  }

  String _getPhoneModelName() {
    if (phoneModel == null) return "Loading...";
    return "${phoneModel!.brand} ${phoneModel!.model}";
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 22, color: Colors.purple),
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
                      widget.service.name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 24),
                    Divider(height: 36, thickness: 1.2),
                    if (errorMessage != null)
                      Container(
                        padding: EdgeInsets.all(16),
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: TextStyle(color: Colors.red[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    _buildInfoRow(
                      "ID",
                      widget.service.id.toString(),
                      icon: Icons.confirmation_number,
                    ),
                    _buildInfoRow(
                      "Name",
                      widget.service.name,
                      icon: Icons.miscellaneous_services,
                    ),
                    _buildInfoRowWithNull(
                      "Description",
                      widget.service.description,
                      icon: Icons.description,
                    ),
                    _buildInfoRow(
                      "Service Fee",
                      "\$${widget.service.serviceFee.toStringAsFixed(2)}",
                      icon: Icons.attach_money,
                    ),
                    _buildInfoRowWithNull(
                      "Estimated Duration",
                      widget.service.estimatedDuration != null 
                          ? "${widget.service.estimatedDuration} hours"
                          : null,
                      icon: Icons.schedule,
                    ),
                    _buildInfoRow(
                      "Status",
                      widget.service.status,
                      icon: Icons.info_outline,
                    ),
                    _buildInfoRowWithNull(
                      "Customer Notes",
                      widget.service.customerNotes,
                      icon: Icons.note,
                    ),
                    _buildInfoRowWithNull(
                      "Technician Notes",
                      widget.service.technicianNotes,
                      icon: Icons.engineering,
                    ),
                    _buildInfoRow(
                      "Created At",
                      _formatDateTime(widget.service.createdAt),
                      icon: Icons.create,
                    ),
                    _buildInfoRowWithNull(
                      "Updated At",
                      widget.service.updatedAt != null ? _formatDateTime(widget.service.updatedAt) : null,
                      icon: Icons.update,
                    ),
                    _buildInfoRowWithNull(
                      "Started At",
                      widget.service.startedAt != null ? _formatDateTime(widget.service.startedAt) : null,
                      icon: Icons.play_arrow,
                    ),
                    _buildInfoRowWithNull(
                      "Completed At",
                      widget.service.completedAt != null ? _formatDateTime(widget.service.completedAt) : null,
                      icon: Icons.check_circle,
                    ),
                    _buildInfoRow(
                      "Customer",
                      _getCustomerName(),
                      icon: Icons.person,
                    ),
                    _buildInfoRowWithNull(
                      "Technician",
                      widget.service.technicianId != null ? _getTechnicianName() : null,
                      icon: Icons.engineering,
                    ),
                    _buildInfoRowWithNull(
                      "Phone Model",
                      widget.service.phoneModelId != null ? _getPhoneModelName() : null,
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
