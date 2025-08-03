import 'package:json_annotation/json_annotation.dart';

part 'part.g.dart';

@JsonSerializable()
class Part {
  final int id;
  final String name;
  final String? description;
  final double price;
  final double? costPrice;
  final int stockQuantity;
  final int? minimumStockLevel;
  final String? sku;
  final String? partNumber;
  final String? brand;
  final String? model;
  final String? color;
  final String? condition;
  final String? grade;
  final bool isActive;
  final bool isOEM;
  final bool isCompatible;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int partCategoryId;
  final String partCategoryName;

  Part({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.costPrice,
    required this.stockQuantity,
    this.minimumStockLevel,
    this.sku,
    this.partNumber,
    this.brand,
    this.model,
    this.color,
    this.condition,
    this.grade,
    required this.isActive,
    required this.isOEM,
    required this.isCompatible,
    required this.createdAt,
    this.updatedAt,
    required this.partCategoryId,
    required this.partCategoryName,
  });

  factory Part.fromJson(Map<String, dynamic> json) => _$PartFromJson(json);
  Map<String, dynamic> toJson() => _$PartToJson(this);
} 