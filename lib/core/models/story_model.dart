import 'package:chat_app/core/models/user_model.dart';
import 'package:flutter/foundation.dart';

class StoryModel {
  final String id;
  final UserModel? user;
  final String caption;
  final String type;
  final String? mediaName;
  final String? mediaUrl;
  final String backgroundUrl;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;
  final DateTime expiresAt;

  StoryModel({
    required this.id,
    required this.user,
    required this.caption,
    required this.type,
    this.mediaName,
    this.mediaUrl,
    required this.backgroundUrl,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
    required this.expiresAt,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    // Handle MongoDB ObjectId format or string IDs
    String parseId(dynamic id) {
      if (id is Map && id.containsKey('\$oid')) {
        return id['\$oid'] as String;
      }
      if (id != null) {
        return id.toString();
      }
      if (kDebugMode) print('parseId: Received null or invalid id: \$id');
      return '';
    }

    // Handle various date formats and potential nulls with detailed logging
    DateTime parseDate(dynamic date, String fieldName) {
      if (date == null) {
        if (kDebugMode) {
          print('parseDate: Received null for date field: \$fieldName');
        }
        return DateTime.now(); // Provide a default or handle as appropriate
      }
      if (date is Map && date.containsKey('\$date')) {
        try {
          return DateTime.parse(date['\$date'] as String);
        } catch (e) {
          if (kDebugMode) {
            print(
              'Error parsing \$date for field \$fieldName: \$e. Value: \${date[\'\\$date\']}',
            );
          }
          return DateTime.now();
        }
      }
      if (date is String) {
        try {
          return DateTime.parse(date);
        } catch (e) {
          if (kDebugMode) {
            print(
              'Error parsing date string for field \$fieldName: \$e. Value: \$date',
            );
          }
          return DateTime.now();
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
              'Error parsing date integer for field \$fieldName: \$e. Value: \$date',
            );
          }
          return DateTime.now();
        }
      }
      // Log unexpected types
      if (kDebugMode) {
        print(
          'parseDate: Received unexpected type for date field \$fieldName: \${date.runtimeType}. Value: \$date',
        );
      }
      return DateTime.now(); // Default for unknown formats or null
    }

    // Safely parse integers, defaulting to 0 if null or invalid
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
              'Error parsing int string for field \$fieldName: \$e. Value: \$value',
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
          'parseInt: Received unexpected type for field \$fieldName: \${value.runtimeType}. Value: \$value',
        );
      }
      return 0; // Default for other types
    }

    // Add detailed logging for all fields received before parsing
    if (kDebugMode) {
      print('--- StoryModel.fromJson Debug Input ---');
      json.forEach((key, value) {
        print('Field: \$key, Type: \${value.runtimeType}, Value: \$value');
      });
      print('--------------------------------------');
    }

    try {
      // Safely handle potentially null or non-map userId with explicit checks
      final dynamic userData = json['userId'];
      UserModel? userModel;
      if (userData != null && userData is Map<String, dynamic>) {
        try {
          userModel = UserModel.fromJson(userData);
        } catch (e) {
          if (kDebugMode) {
            print(
              'Error parsing UserModel from userId: \$e. userId data: \$userData',
            );
          }
          userModel = null; // Set to null on parsing error
        }
      } else {
        if (kDebugMode) {
          print(
            'userId is null or not a Map<String, dynamic>. Type: \${userData.runtimeType}. Value: \$userData',
          );
        }
        userModel = null; // Set to null if userId is null or not a map
      }

      return StoryModel(
        id: parseId(json['_id']),
        user: userModel, // Use the potentially null userModel
        caption:
            json['caption'] as String? ?? '', // Handle potential null caption
        type: json['type'] as String? ?? '', // Handle potential null type
        mediaName: json['mediaName'] as String?,
        mediaUrl: json['mediaUrl'] as String?,
        backgroundUrl:
            json['backgroundUrl'] as String? ??
            '', // Handle potential null backgroundUrl, assuming nullable string
        likeCount: parseInt(
          json['likes'],
          'likes',
        ), // Use safe parseInt with field name
        commentCount: parseInt(
          json['commentCount'],
          'commentCount',
        ), // Use safe parseInt with field name
        createdAt: parseDate(
          json['createdAt'],
          'createdAt',
        ), // Use safe parseDate with field name
        expiresAt: parseDate(
          json['expiresAt'],
          'expiresAt',
        ), // Use safe parseDate with field name
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error creating StoryModel from JSON: \$e');
        print('JSON data that caused error: \$json');
      }
      // Re-throwing the error is important so the calling code knows something went wrong
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': user?.toJson(), // Handle nullable user in toJson
      'caption': caption,
      'type': type,
      'mediaName': mediaName,
      'mediaUrl': mediaUrl,
      'backgroundUrl': backgroundUrl,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  // Check if story is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
