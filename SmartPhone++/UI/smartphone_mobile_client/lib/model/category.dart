import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? parentCategoryId;
  final String? parentCategoryName;
  final int productCount;

  Category({
    this.id = 0,
    this.name = '',
    this.description,
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.parentCategoryId,
    this.parentCategoryName,
    this.productCount = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
} 