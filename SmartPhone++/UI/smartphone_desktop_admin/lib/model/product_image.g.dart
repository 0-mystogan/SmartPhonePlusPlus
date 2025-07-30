// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductImage _$ProductImageFromJson(Map<String, dynamic> json) => ProductImage(
      id: json['id'] as int? ?? 0,
      imageUrl: json['imageUrl'] as String? ?? '',
      altText: json['altText'] as String?,
      isPrimary: json['isPrimary'] as bool? ?? false,
      displayOrder: json['displayOrder'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      productId: json['productId'] as int? ?? 0,
    );

Map<String, dynamic> _$ProductImageToJson(ProductImage instance) => <String, dynamic>{
      'id': instance.id,
      'imageUrl': instance.imageUrl,
      'altText': instance.altText,
      'isPrimary': instance.isPrimary,
      'displayOrder': instance.displayOrder,
      'createdAt': instance.createdAt.toIso8601String(),
      'productId': instance.productId,
    }; 