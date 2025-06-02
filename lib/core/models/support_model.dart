import 'package:chat_app/core/models/user_model.dart';

class SupportModel {
  final String id;
  final UserModel user;
  final String subject;
  final String message;
  final String category;
  final String status;
  final String priority;
  final List<SupportAttachment>? attachments;
  final List<SupportResponse>? responses;
  final String? assignedTo;
  final DateTime? closedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupportModel({
    required this.id,
    required this.user,
    required this.subject,
    required this.message,
    required this.category,
    required this.status,
    required this.priority,
    this.attachments,
    this.responses,
    this.assignedTo,
    this.closedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupportModel.fromJson(Map<String, dynamic> json) {
    return SupportModel(
      id: json['_id'] as String,
      user: UserModel.fromJson(json['userId'] as Map<String, dynamic>),
      subject: json['subject'] as String,
      message: json['message'] as String,
      category: json['category'] as String,
      status: json['status'] as String,
      priority: json['priority'] as String,
      attachments:
          json['attachments'] != null
              ? (json['attachments'] as List)
                  .map(
                    (a) =>
                        SupportAttachment.fromJson(a as Map<String, dynamic>),
                  )
                  .toList()
              : null,
      responses:
          json['responses'] != null
              ? (json['responses'] as List)
                  .map(
                    (r) => SupportResponse.fromJson(r as Map<String, dynamic>),
                  )
                  .toList()
              : null,
      assignedTo: json['assignedTo'] as String?,
      closedAt:
          json['closedAt'] != null
              ? DateTime.parse(json['closedAt'] as String)
              : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': user.toJson(),
      'subject': subject,
      'message': message,
      'category': category,
      'status': status,
      'priority': priority,
      'attachments': attachments?.map((a) => a.toJson()).toList(),
      'responses': responses?.map((r) => r.toJson()).toList(),
      'assignedTo': assignedTo,
      'closedAt': closedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Get time elapsed since creation
  String get timeElapsed {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}

class SupportAttachment {
  final String url;
  final String type;
  final String name;

  SupportAttachment({
    required this.url,
    required this.type,
    required this.name,
  });

  factory SupportAttachment.fromJson(Map<String, dynamic> json) {
    return SupportAttachment(
      url: json['url'] as String,
      type: json['type'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'url': url, 'type': type, 'name': name};
  }
}

class SupportResponse {
  final String adminId;
  final String message;
  final DateTime createdAt;

  SupportResponse({
    required this.adminId,
    required this.message,
    required this.createdAt,
  });

  factory SupportResponse.fromJson(Map<String, dynamic> json) {
    return SupportResponse(
      adminId: json['adminId'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adminId': adminId,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
