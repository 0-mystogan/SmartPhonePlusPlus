import 'package:json_annotation/json_annotation.dart';
import 'package:smartphone_mobile_client/model/product_image.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  @JsonKey(name: 'id')
  final int id;
  @JsonKey(name: 'name')
  final String name;
  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(name: 'currentPrice')
  final double? currentPrice;
  @JsonKey(name: 'originalPrice')
  final double? originalPrice;
  @JsonKey(name: 'stockQuantity')
  final int stockQuantity;
  @JsonKey(name: 'minimumStockLevel')
  final int? minimumStockLevel;
  @JsonKey(name: 'sku')
  final String? sku;
  @JsonKey(name: 'brand')
  final String? brand;
  @JsonKey(name: 'model')
  final String? model;
  @JsonKey(name: 'color')
  final String? color;
  @JsonKey(name: 'size')
  final String? size;
  @JsonKey(name: 'weight')
  final String? weight;
  @JsonKey(name: 'dimensions')
  final String? dimensions;
  @JsonKey(name: 'isActive')
  final bool isActive;
  @JsonKey(name: 'isFeatured')
  final bool isFeatured;
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;
  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;
  @JsonKey(name: 'categoryId')
  final int categoryId;
  @JsonKey(name: 'categoryName')
  final String? categoryName; // For display purposes
  @JsonKey(name: 'productImages')
  final List<ProductImage>? productImages;

  Product({
    this.id = 0,
    this.name = '',
    this.description,
    this.currentPrice,
    this.originalPrice,
    this.stockQuantity = 0,
    this.minimumStockLevel,
    this.sku,
    this.brand,
    this.model,
    this.color,
    this.size,
    this.weight,
    this.dimensions,
    this.isActive = true,
    this.isFeatured = false,
    required this.createdAt,
    this.updatedAt,
    this.categoryId = 0,
    this.categoryName,
    this.productImages,
  });

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
} 