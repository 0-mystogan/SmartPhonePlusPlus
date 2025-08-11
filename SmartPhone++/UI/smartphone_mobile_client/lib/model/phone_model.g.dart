// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhoneModel _$PhoneModelFromJson(Map<String, dynamic> json) => PhoneModel(
      id: json['id'] as int,
      brand: json['brand'] as String,
      model: json['model'] as String,
      series: json['series'] as String?,
      year: json['year'] as String?,
      color: json['color'] as String?,
      storage: json['storage'] as String?,
      ram: json['ram'] as String?,
      network: json['network'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PhoneModelToJson(PhoneModel instance) => <String, dynamic>{
      'id': instance.id,
      'brand': instance.brand,
      'model': instance.model,
      'series': instance.series,
      'year': instance.year,
      'color': instance.color,
      'storage': instance.storage,
      'ram': instance.ram,
      'network': instance.network,
      'imageUrl': instance.imageUrl,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    }; 