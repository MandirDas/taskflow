import 'package:json_annotation/json_annotation.dart';

part 'organization_model.g.dart';

/// Data model for Organization, handles JSON serialization.

@JsonSerializable()
class OrganizationModel {
  final String id;
  final String name;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const OrganizationModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory OrganizationModel.fromJson(Map<String, dynamic> json) =>
      _$OrganizationModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationModelToJson(this);
}
