import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chat_app/core/config/index.dart';
import '../models/profile_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';

class ProfileRemoteDataSource {
  final String baseUrl = '${Config.apiUrl}/profiles';
  final http.Client client;

  ProfileRemoteDataSource({http.Client? client})
    : client = client ?? http.Client();

  Future<ProfileModel> getProfile(String userId) async {
    final token = await getToken();

    final response = await client.get(
      Uri.parse('$baseUrl/get/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print('Status: ${response.statusCode}, Body: ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['profile'] != null) {
        return ProfileModel.fromJson(data['profile']);
      } else {
        throw Exception('Profile not found');
      }
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<ProfileModel> editProfile(Map<String, dynamic> data) async {
    final token = await getToken();
    final response = await client.put(
      Uri.parse('$baseUrl/edit'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      final resData = jsonDecode(response.body);
      return ProfileModel.fromJson(resData['user']);
    } else {
      throw Exception('Failed to edit profile: ${response.body}');
    }
  }

  Future<List<ProfileModel>> searchProfile(String query) async {
    final token = await getToken();
    final response = await client.get(
      Uri.parse('$baseUrl/search?query=$query'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final users = data['users'] as List;
      return users.map((e) => ProfileModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to search profile');
    }
  }

  Future<String> uploadProfileImage(File image) async {
    final uri = Uri.parse('${Config.apiUrl}/profiles/upload-image');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', image.path));
    final response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      // Parse respStr to get the image URL, e.g.:
      // final imageUrl = jsonDecode(respStr)['url'];
      // return imageUrl;
      // For demo, just return respStr:
      return respStr;
    } else {
      throw Exception('Failed to upload image');
    }
  }
}

Future<String?> getToken() async {
  final storage = FlutterSecureStorage();
  return await storage.read(key: 'token');
}
