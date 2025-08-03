import 'package:json_annotation/json_annotation.dart';

part 'phone_model.g.dart';

@JsonSerializable()
class PhoneModel {
  final int id;
  final String brand;
  final String model;
  final String? series;
  final String? year;
  final String? color;
  final String? storage;
  final String? ram;
  final String? network;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PhoneModel({
    required this.id,
    required this.brand,
    required this.model,
    this.series,
    this.year,
    this.color,
    this.storage,
    this.ram,
    this.network,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory PhoneModel.fromJson(Map<String, dynamic> json) => _$PhoneModelFromJson(json);
  Map<String, dynamic> toJson() => _$PhoneModelToJson(this);
} 