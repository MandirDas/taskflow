import 'package:json_annotation/json_annotation.dart';

part 'auth_credentials_model.g.dart';

/// Model representing test credentials from the mock JSON.

@JsonSerializable()
class AuthCredentialsModel {
  final String email;
  final String password;
  @JsonKey(name: 'org_id')
  final String orgId;
  final String role;

  const AuthCredentialsModel({
    required this.email,
    required this.password,
    required this.orgId,
    required this.role,
  });

  factory AuthCredentialsModel.fromJson(Map<String, dynamic> json) =>
      _$AuthCredentialsModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthCredentialsModelToJson(this);
}
