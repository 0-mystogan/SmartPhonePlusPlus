// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductImage _$ProductImageFromJson(Map<String, dynamic> json) => ProductImage(
  id: (json['id'] as num?)?.toInt() ?? 0,
  imageData: json['imageData'] as String?,
  fileName: json['fileName'] as String?,
  contentType: json['contentType'] as String?,
  altText: json['altText'] as String?,
  isPrimary: json['isPrimary'] as bool? ?? false,
  displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  productId: (json['productId'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ProductImageToJson(ProductImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imageData': instance.imageData,
      'fileName': instance.fileName,
      'contentType': instance.contentType,
      'altText': instance.altText,
      'isPrimary': instance.isPrimary,
      'displayOrder': instance.displayOrder,
      'createdAt': instance.createdAt.toIso8601String(),
      'productId': instance.productId,
    };
