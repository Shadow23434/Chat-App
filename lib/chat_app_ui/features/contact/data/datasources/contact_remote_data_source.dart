import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chat_app/core/config/api_config.dart';
import '../models/contact_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<String?> getToken() async {
  final storage = FlutterSecureStorage();
  return await storage.read(key: 'token');
}

class ContactRemoteDataSource {
  final String? token;

  ContactRemoteDataSource({this.token});

  Map<String, String> get _headers => {
    ...ApiConfig.headers,
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Future<List<ContactModel>> getContacts() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/contacts/get'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<ContactModel> accepted =
          (data['accepted'] as List<dynamic>?)
              ?.map((e) => ContactModel.fromJson(e))
              .toList() ??
          [];
      final List<ContactModel> pending =
          (data['pending'] as List<dynamic>?)
              ?.map((e) => ContactModel.fromJson(e))
              .toList() ??
          [];
      return [...accepted, ...pending];
    } else {
      throw Exception('Failed to fetch contacts');
    }
  }

  Future<void> addContact(String email) async {
    String? authToken = token;
    if (authToken == null) {
      authToken = await getToken();
      if (authToken == null) {
        throw Exception('No authentication token');
      }
    }
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/contacts/add'),
      headers: {..._headers, 'Authorization': 'Bearer $authToken'},
      body: json.encode({'email': email}),
    );

    if (response.statusCode != 201) {
      final body = json.decode(response.body);
      throw Exception(body['error'] ?? 'Failed to add contact');
    }
  }

  Future<void> acceptContact(String contactId) async {
    String? authToken = token;
    if (authToken == null) {
      authToken = await getToken();
      if (authToken == null) {
        throw Exception('No authentication token');
      }
    }
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/contacts/accept/$contactId'),
      headers: {..._headers, 'Authorization': 'Bearer $authToken'},
    );
    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['error'] ?? 'Failed to accept contact');
    }
  }

  Future<void> deleteContact(String contactId) async {
    String? authToken = token;
    if (authToken == null) {
      authToken = await getToken();
      if (authToken == null) {
        throw Exception('No authentication token');
      }
    }
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/contacts/delete/$contactId'),
      headers: {..._headers, 'Authorization': 'Bearer $authToken'},
    );
    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['error'] ?? 'Failed to delete contact');
    }
  }
}
