import 'package:json_annotation/json_annotation.dart';

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

  Service({
    this.id = 0,
    this.name = '',
    this.description,
    this.serviceFee = 0.0,
    this.estimatedDuration,
    this.status = '',
    this.customerNotes,
    this.technicianNotes,
    required this.createdAt,
    this.updatedAt,
    this.startedAt,
    this.completedAt,
    this.userId = 0,
    this.technicianId,
    this.phoneModelId,
  });

  factory Service.fromJson(Map<String, dynamic> json) =>
      _$ServiceFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceToJson(this);
}
