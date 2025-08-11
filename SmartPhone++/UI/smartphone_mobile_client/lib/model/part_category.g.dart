// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'part_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartCategory _$PartCategoryFromJson(Map<String, dynamic> json) => PartCategory(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  description: json['description'] as String?,
  imageUrl: json['imageUrl'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  parentCategoryId: (json['parentCategoryId'] as num?)?.toInt(),
  parentCategoryName: json['parentCategoryName'] as String?,
);

Map<String, dynamic> _$PartCategoryToJson(PartCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'parentCategoryId': instance.parentCategoryId,
      'parentCategoryName': instance.parentCategoryName,
    };
