import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/org_member.dart';

part 'org_member_model.g.dart';

/// Data model for OrgMember, handles JSON serialization.

@JsonSerializable()
class OrgMemberModel {
  @JsonKey(name: 'org_id')
  final String orgId;

  @JsonKey(name: 'user_id')
  final String userId;

  final String role;

  const OrgMemberModel({
    required this.orgId,
    required this.userId,
    required this.role,
  });

  factory OrgMemberModel.fromJson(Map<String, dynamic> json) =>
      _$OrgMemberModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrgMemberModelToJson(this);

  /// Convert to domain entity
  OrgMember toEntity() => OrgMember(
        orgId: orgId,
        userId: userId,
        role: role,
      );

  /// Create from domain entity
  factory OrgMemberModel.fromEntity(OrgMember entity) => OrgMemberModel(
        orgId: entity.orgId,
        userId: entity.userId,
        role: entity.role,
      );
}
