import 'dart:convert';
import 'package:chat_app/chat_app_ui/core/error/exceptions.dart';
import 'package:chat_app/chat_app_ui/features/call/data/models/call_model.dart';
import 'package:http/http.dart' as http;

abstract class CallRemoteDataSource {
  Future<List<CallModel>> getCalls();
}

class CallRemoteDataSourceImpl implements CallRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  CallRemoteDataSourceImpl({required this.client, required this.baseUrl});

  @override
  Future<List<CallModel>> getCalls() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/calls/get'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => CallModel.fromJson(json)).toList();
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }
}
