// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  description: json['description'] as String?,
  currentPrice: (json['currentPrice'] as num?)?.toDouble(),
  originalPrice: (json['originalPrice'] as num?)?.toDouble(),
  stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 0,
  minimumStockLevel: (json['minimumStockLevel'] as num?)?.toInt(),
  sku: json['sku'] as String?,
  brand: json['brand'] as String?,
  model: json['model'] as String?,
  color: json['color'] as String?,
  size: json['size'] as String?,
  weight: json['weight'] as String?,
  dimensions: json['dimensions'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  isFeatured: json['isFeatured'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  categoryId: (json['categoryId'] as num?)?.toInt() ?? 0,
  categoryName: json['categoryName'] as String?,
  productImages: (json['productImages'] as List<dynamic>?)
      ?.map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'currentPrice': instance.currentPrice,
  'originalPrice': instance.originalPrice,
  'stockQuantity': instance.stockQuantity,
  'minimumStockLevel': instance.minimumStockLevel,
  'sku': instance.sku,
  'brand': instance.brand,
  'model': instance.model,
  'color': instance.color,
  'size': instance.size,
  'weight': instance.weight,
  'dimensions': instance.dimensions,
  'isActive': instance.isActive,
  'isFeatured': instance.isFeatured,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'categoryId': instance.categoryId,
  'categoryName': instance.categoryName,
  'productImages': instance.productImages,
};
