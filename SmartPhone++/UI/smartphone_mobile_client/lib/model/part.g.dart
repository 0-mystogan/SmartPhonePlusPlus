// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'part.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Part _$PartFromJson(Map<String, dynamic> json) => Part(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      costPrice: json['costPrice'] == null
          ? null
          : (json['costPrice'] as num).toDouble(),
      stockQuantity: json['stockQuantity'] as int,
      minimumStockLevel: json['minimumStockLevel'] as int?,
      sku: json['sku'] as String?,
      partNumber: json['partNumber'] as String?,
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      color: json['color'] as String?,
      condition: json['condition'] as String?,
      grade: json['grade'] as String?,
      isActive: json['isActive'] as bool,
      isOEM: json['isOEM'] as bool,
      isCompatible: json['isCompatible'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      partCategoryId: json['partCategoryId'] as int,
      partCategoryName: json['partCategoryName'] as String,
    );

Map<String, dynamic> _$PartToJson(Part instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'costPrice': instance.costPrice,
      'stockQuantity': instance.stockQuantity,
      'minimumStockLevel': instance.minimumStockLevel,
      'sku': instance.sku,
      'partNumber': instance.partNumber,
      'brand': instance.brand,
      'model': instance.model,
      'color': instance.color,
      'condition': instance.condition,
      'grade': instance.grade,
      'isActive': instance.isActive,
      'isOEM': instance.isOEM,
      'isCompatible': instance.isCompatible,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'partCategoryId': instance.partCategoryId,
      'partCategoryName': instance.partCategoryName,
    }; 