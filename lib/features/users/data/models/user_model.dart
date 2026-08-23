import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

/// Data model for User, handles JSON serialization.

@JsonSerializable()
class UserModel {
  final String id;
  final String name;
  final String email;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Convert to domain entity
  UserEntity toEntity() => UserEntity(
        id: id,
        name: name,
        email: email,
        avatarUrl: avatarUrl,
      );

  /// Create from domain entity
  factory UserModel.fromEntity(UserEntity entity) => UserModel(
        id: entity.id,
        name: entity.name,
        email: entity.email,
        avatarUrl: entity.avatarUrl,
      );
}
