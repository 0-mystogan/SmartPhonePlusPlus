import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'product_image.g.dart';

@JsonSerializable()
class ProductImage {
  final int id;
  final String? imageData; // Base64 string from backend
  final String? fileName;
  final String? contentType;
  final String? altText;
  final bool isPrimary;
  final int displayOrder;
  final DateTime createdAt;
  final int productId;

  ProductImage({
    this.id = 0,
    this.imageData,
    this.fileName,
    this.contentType,
    this.altText,
    this.isPrimary = false,
    this.displayOrder = 0,
    required this.createdAt,
    this.productId = 0,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) => _$ProductImageFromJson(json);
  Map<String, dynamic> toJson() => _$ProductImageToJson(this);
} 