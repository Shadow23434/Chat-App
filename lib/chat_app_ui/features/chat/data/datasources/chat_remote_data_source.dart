import 'dart:convert';

import 'package:chat_app/chat_app_ui/features/chat/data/models/chat_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChatRemoteDataSource {
  final String baseUrl;
  final _storage = FlutterSecureStorage();

  ChatRemoteDataSource() : baseUrl = dotenv.get('CHAT_URL');

  Future<List<ChatModel>> fetchChats() async {
    String token = await _storage.read(key: 'token') ?? '';
    final response = await http.get(
      Uri.parse('$baseUrl/get-chat'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => ChatModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch chats');
    }
  }
}
