// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Service _$ServiceFromJson(Map<String, dynamic> json) => Service(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  description: json['description'] as String?,
  serviceFee: (json['serviceFee'] as num?)?.toDouble() ?? 0.0,
  estimatedDuration: (json['estimatedDuration'] as num?)?.toDouble(),
  status: json['status'] as String? ?? '',
  customerNotes: json['customerNotes'] as String?,
  technicianNotes: json['technicianNotes'] as String?,
  createdAt: json['createdAt'] == null ? DateTime.now() : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null ? null : DateTime.parse(json['updatedAt'] as String),
  startedAt: json['startedAt'] == null ? null : DateTime.parse(json['startedAt'] as String),
  completedAt: json['completedAt'] == null ? null : DateTime.parse(json['completedAt'] as String),
  userId: (json['userId'] as num?)?.toInt() ?? 0,
  technicianId: (json['technicianId'] as num?)?.toInt(),
  phoneModelId: (json['phoneModelId'] as num?)?.toInt(),
);

Map<String, dynamic> _$ServiceToJson(Service instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'serviceFee': instance.serviceFee,
  'estimatedDuration': instance.estimatedDuration,
  'status': instance.status,
  'customerNotes': instance.customerNotes,
  'technicianNotes': instance.technicianNotes,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'startedAt': instance.startedAt?.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'userId': instance.userId,
  'technicianId': instance.technicianId,
  'phoneModelId': instance.phoneModelId,
};
