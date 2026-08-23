// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentModel _$CommentModelFromJson(Map<String, dynamic> json) => CommentModel(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      authorId: json['author_id'] as String,
      body: json['body'] as String,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$CommentModelToJson(CommentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'task_id': instance.taskId,
      'author_id': instance.authorId,
      'body': instance.body,
      'created_at': instance.createdAt,
    };
