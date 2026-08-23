// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_credentials_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthCredentialsModel _$AuthCredentialsModelFromJson(
        Map<String, dynamic> json) =>
    AuthCredentialsModel(
      email: json['email'] as String,
      password: json['password'] as String,
      orgId: json['org_id'] as String,
      role: json['role'] as String,
    );

Map<String, dynamic> _$AuthCredentialsModelToJson(
        AuthCredentialsModel instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'org_id': instance.orgId,
      'role': instance.role,
    };
