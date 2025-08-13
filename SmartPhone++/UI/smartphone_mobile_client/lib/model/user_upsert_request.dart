import 'package:json_annotation/json_annotation.dart';
import 'role_response.dart';

part 'user_upsert_request.g.dart';

@JsonSerializable()
class UserUpsertRequest {
  final String firstName;
  final String lastName;
  final String? picture;
  final String email;
  final String username;
  final String? phoneNumber;
  final int genderId;
  final int cityId;
  final bool isActive;
  final String? password;
  final List<int> roleIds;

  UserUpsertRequest({
    required this.firstName,
    required this.lastName,
    this.picture,
    required this.email,
    required this.username,
    this.phoneNumber,
    required this.genderId,
    required this.cityId,
    this.isActive = true,
    this.password,
    this.roleIds = const [],
  });

  factory UserUpsertRequest.fromJson(Map<String, dynamic> json) => _$UserUpsertRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UserUpsertRequestToJson(this);
}
