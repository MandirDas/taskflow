import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/comment_entity.dart';

part 'comment_model.g.dart';

/// Data model for Comment, handles JSON serialization.

@JsonSerializable()
class CommentModel {
  final String id;
  @JsonKey(name: 'task_id')
  final String taskId;
  @JsonKey(name: 'author_id')
  final String authorId;
  final String body;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const CommentModel({
    required this.id,
    required this.taskId,
    required this.authorId,
    required this.body,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommentModelToJson(this);

  /// Convert to domain entity
  CommentEntity toEntity() => CommentEntity(
        id: id,
        taskId: taskId,
        authorId: authorId,
        body: body,
        createdAt: DateTime.parse(createdAt),
      );

  /// Create from domain entity
  factory CommentModel.fromEntity(CommentEntity entity) => CommentModel(
        id: entity.id,
        taskId: entity.taskId,
        authorId: entity.authorId,
        body: entity.body,
        createdAt: entity.createdAt.toIso8601String(),
      );
}
