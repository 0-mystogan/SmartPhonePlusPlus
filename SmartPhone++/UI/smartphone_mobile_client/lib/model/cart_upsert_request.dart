import 'package:json_annotation/json_annotation.dart';

part 'cart_upsert_request.g.dart';

@JsonSerializable()
class CartUpsertRequest {
  final DateTime? expiresAt;
  final bool isActive;
  final int userId;

  CartUpsertRequest({
    this.expiresAt,
    this.isActive = true,
    required this.userId,
  });

  factory CartUpsertRequest.fromJson(Map<String, dynamic> json) => _$CartUpsertRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CartUpsertRequestToJson(this);
}
