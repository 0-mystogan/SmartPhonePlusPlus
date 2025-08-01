import 'package:json_annotation/json_annotation.dart';

part 'part_category.g.dart';

@JsonSerializable()
class PartCategory {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? parentCategoryId;
  final String? parentCategoryName;

  PartCategory({
    this.id = 0,
    this.name = '',
    this.description,
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.parentCategoryId,
    this.parentCategoryName,
  });

  factory PartCategory.fromJson(Map<String, dynamic> json) => _$PartCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$PartCategoryToJson(this);
} 