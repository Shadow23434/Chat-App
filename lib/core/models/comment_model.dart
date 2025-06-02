import 'package:chat_app/core/models/user_model.dart';
import 'package:flutter/foundation.dart';

class CommentModel {
  final String id;
  final UserModel? userId;
  final String content;
  final int likes;
  final DateTime createdAt;
  final String? parentCommentId;

  CommentModel({
    required this.id,
    this.userId,
    required this.content,
    required this.likes,
    required this.createdAt,
    this.parentCommentId,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    String parseId(dynamic id) {
      if (id is Map && id.containsKey('\$oid')) {
        return id['\$oid'] as String;
      }
      if (id != null) {
        return id.toString();
      }
      return ''; // Default to empty string if id is null/invalid
    }

    UserModel? parseUser(dynamic userData) {
      if (userData != null && userData is Map<String, dynamic>) {
        try {
          return UserModel.fromJson(userData);
        } catch (e) {
          if (kDebugMode) {
            print(
              'Error parsing UserModel from comment userId data: \$e. Data: \$userData',
            );
          }
          return null; // Return null on parsing error
        }
      }
      return null; // Return null if userData is null or not a map
    }

    DateTime parseDate(dynamic date, String fieldName) {
      if (date == null) {
        if (kDebugMode) {
          print('parseDate: Received null for comment date field: \$fieldName');
        }
        return DateTime.now(); // Provide a default or handle as appropriate
      }
      if (date is String) {
        try {
          return DateTime.parse(date);
        } catch (e) {
          if (kDebugMode) {
            print(
              'Error parsing date string for comment field \$fieldName: \$e. Value: \$date',
            );
          }
          return DateTime.now(); // Default to current time on error
        }
      }
      if (date is Map && date.containsKey('\$date')) {
        try {
          return DateTime.parse(date['\$date'] as String);
        } catch (e) {
          if (kDebugMode) {
            print(
              'Error parsing \$date for comment field \$fieldName: \$e. Value: \${date[\'\\$date\']}',
            );
          }
          return DateTime.now(); // Default to current time on error
        }
      }
      if (date is int) {
        try {
          return DateTime.fromMillisecondsSinceEpoch(
            date,
          ); // Assuming milliseconds timestamp
        } catch (e) {
          if (kDebugMode) {
            print(
              'Error parsing date integer for comment field \$fieldName: \$e. Value: \$date',
            );
          }
          return DateTime.now();
        }
      }
      if (kDebugMode) {
        print(
          'Unexpected date type for comment field \$fieldName: \${date.runtimeType}. Value: \$date',
        );
      }
      return DateTime.now(); // Default for other types or null
    }

    int parseInt(dynamic value, String fieldName) {
      if (value == null) return 0; // Default for null
      if (value is int) {
        return value;
      } else if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          if (kDebugMode) {
            print(
              'Error parsing int string for comment field \$fieldName: \$e. Value: \$value',
            );
          }
          return 0;
        }
      } else if (value is double) {
        return value.toInt();
      } else if (value is List) {
        // Handle cases where a count might be represented as a list length
        return value.length;
      }
      if (kDebugMode) {
        print(
          'parseInt: Received unexpected type for comment field \$fieldName: \${value.runtimeType}. Value: \$value',
        );
      }
      return 0; // Default for other types
    }

    return CommentModel(
      id: parseId(json['_id']),
      userId: parseUser(json['userId']),
      content: json['content'] as String? ?? '',
      likes: parseInt(json['likes'], 'likes'),
      createdAt: parseDate(json['createdAt'], 'createdAt'),
      parentCommentId: json['parentCommentId'] as String?,
    );
  }
}
