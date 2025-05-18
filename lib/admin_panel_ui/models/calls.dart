import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Call {
  final String id;
  final String callerId;
  final String receiverId;
  final String status;
  final int duration;
  final DateTime startedAt;
  final DateTime? endedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Call({
    required this.id,
    required this.callerId,
    required this.receiverId,
    required this.status,
    required this.duration,
    required this.startedAt,
    this.endedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Call.fromJson(Map<String, dynamic> json) {
    return Call(
      id: json['_id']?['\$oid'] ?? '',
      callerId: json['callerId']?['\$oid'] ?? '',
      receiverId: json['receiverId']?['\$oid'] ?? '',
      status: json['status'] ?? 'unknown',
      duration: json['duration'] ?? 0,
      startedAt:
          json['startedAt'] != null && json['startedAt']['\$date'] != null
              ? DateTime.parse(json['startedAt']['\$date'])
              : DateTime.now(),
      endedAt:
          json['endedAt'] != null && json['endedAt']['\$date'] != null
              ? DateTime.parse(json['endedAt']['\$date'])
              : null,
      createdAt:
          json['createdAt'] != null && json['createdAt']['\$date'] != null
              ? DateTime.parse(json['createdAt']['\$date'])
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null && json['updatedAt']['\$date'] != null
              ? DateTime.parse(json['updatedAt']['\$date'])
              : DateTime.now(),
    );
  }

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedDate {
    return DateFormat('MMM dd, yyyy').format(startedAt);
  }

  String get formattedTime {
    return DateFormat('HH:mm').format(startedAt);
  }

  Color get statusColor {
    switch (status) {
      case 'received':
        return Colors.green;
      case 'missed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'received':
        return Icons.call_received;
      case 'missed':
        return Icons.call_missed;
      default:
        return Icons.call;
    }
  }
}
