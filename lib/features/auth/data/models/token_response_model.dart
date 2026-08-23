import 'package:json_annotation/json_annotation.dart';

part 'token_response_model.g.dart';

/// Model representing the mock login response with tokens.

@JsonSerializable()
class TokenResponseModel {
  @JsonKey(name: 'access_token')
  final String accessToken;

  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  @JsonKey(name: 'access_token_expires_in_seconds')
  final int accessTokenExpiresInSeconds;

  @JsonKey(name: 'refresh_token_expires_in_seconds')
  final int refreshTokenExpiresInSeconds;

  const TokenResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresInSeconds,
    required this.refreshTokenExpiresInSeconds,
  });

  factory TokenResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$TokenResponseModelToJson(this);
}
