import 'package:json_annotation/json_annotation.dart';
import 'package:smartphone_mobile_client/model/service_user.dart';
import 'package:smartphone_mobile_client/model/phone_model.dart';

part 'service.g.dart';

@JsonSerializable()
class Service {
  final int id;
  final String name;
  final String? description;
  final double serviceFee;
  final double? estimatedDuration;
  final String status;
  final String? customerNotes;
  final String? technicianNotes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int userId;
  final int? technicianId;
  final int? phoneModelId;
  
  // Navigation properties
  final ServiceUser? user;
  final ServiceUser? technician;
  final PhoneModel? phoneModel;

  Service({
    required this.id,
    required this.name,
    this.description,
    required this.serviceFee,
    this.estimatedDuration,
    required this.status,
    this.customerNotes,
    this.technicianNotes,
    required this.createdAt,
    this.updatedAt,
    this.startedAt,
    this.completedAt,
    required this.userId,
    this.technicianId,
    this.phoneModelId,
    this.user,
    this.technician,
    this.phoneModel,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      serviceFee: (json['serviceFee'] ?? 0.0).toDouble(),
      estimatedDuration: json['estimatedDuration'] != null ? (json['estimatedDuration'] as num).toDouble() : null,
      status: json['status'] ?? '',
      customerNotes: json['customerNotes'],
      technicianNotes: json['technicianNotes'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      userId: json['userId'] ?? 0,
      technicianId: json['technicianId'],
      phoneModelId: json['phoneModelId'],
      user: json['user'] != null ? ServiceUser.fromJson(json['user']) : null,
      technician: json['technician'] != null ? ServiceUser.fromJson(json['technician']) : null,
      phoneModel: json['phoneModel'] != null ? PhoneModel.fromJson(json['phoneModel']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'serviceFee': serviceFee,
      'estimatedDuration': estimatedDuration,
      'status': status,
      'customerNotes': customerNotes,
      'technicianNotes': technicianNotes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'userId': userId,
      'technicianId': technicianId,
      'phoneModelId': phoneModelId,
      'user': user?.toJson(),
      'technician': technician?.toJson(),
      'phoneModel': phoneModel?.toJson(),
    };
  }
}
