// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenResponseModel _$TokenResponseModelFromJson(Map<String, dynamic> json) =>
    TokenResponseModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      accessTokenExpiresInSeconds:
          (json['access_token_expires_in_seconds'] as num).toInt(),
      refreshTokenExpiresInSeconds:
          (json['refresh_token_expires_in_seconds'] as num).toInt(),
    );

Map<String, dynamic> _$TokenResponseModelToJson(TokenResponseModel instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'access_token_expires_in_seconds': instance.accessTokenExpiresInSeconds,
      'refresh_token_expires_in_seconds': instance.refreshTokenExpiresInSeconds,
    };
