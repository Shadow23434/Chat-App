import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/core/config/index.dart';

/// Safe asset loader to handle encoding issues
class SafeAssetLoader {
  static Map<String, String>? _cachedEnv;

  /// Load a JSON asset file safely
  static Future<Map<String, dynamic>> loadJsonAsset(String assetPath) async {
    try {
      // Load file as ByteData
      final ByteData data = await rootBundle.load(assetPath);

      // Convert ByteData to List<int>
      final List<int> bytes = data.buffer.asUint8List();

      // Try to decode with UTF-8
      try {
        final String jsonString = utf8.decode(bytes);
        return json.decode(jsonString) as Map<String, dynamic>;
      } catch (utf8Error) {
        print('UTF-8 decode error: $utf8Error');

        // Try with Latin-1 encoding (ISO-8859-1) as fallback
        final String jsonString = latin1.decode(bytes);
        return json.decode(jsonString) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error loading asset $assetPath: $e');
      return {}; // Return empty map instead of throwing
    }
  }

  /// Load a JSON array asset file safely
  static Future<List<dynamic>> loadJsonArrayAsset(String assetPath) async {
    try {
      // Load file as ByteData
      final ByteData data = await rootBundle.load(assetPath);

      // Convert ByteData to List<int>
      final List<int> bytes = data.buffer.asUint8List();

      // Try to decode with UTF-8
      try {
        final String jsonString = utf8.decode(bytes);
        return json.decode(jsonString) as List<dynamic>;
      } catch (utf8Error) {
        print('UTF-8 decode error: $utf8Error');

        // Try with Latin-1 encoding (ISO-8859-1) as fallback
        final String jsonString = latin1.decode(bytes);
        return json.decode(jsonString) as List<dynamic>;
      }
    } catch (e) {
      print('Error loading asset $assetPath: $e');
      return []; // Return empty list instead of throwing
    }
  }

  /// Load .env file safely with multiple approaches
  static Future<Map<String, String>> loadEnvFile() async {
    // Return cached version if available
    if (_cachedEnv != null) {
      return _cachedEnv!;
    }

    Map<String, String> envMap = {};

    // Try methods in order: asset bundle, direct file read, default
    envMap =
        await _loadEnvFromAssets() ??
        await _loadEnvFromFile() ??
        _getDefaultEnv();

    // Validate critical environment variables
    _validateEnvVariables(envMap);

    // Cache the result
    _cachedEnv = envMap;

    return envMap;
  }

  /// Try loading from asset bundle
  static Future<Map<String, String>?> _loadEnvFromAssets() async {
    try {
      final ByteData data = await rootBundle.load('.env');
      final List<int> bytes = data.buffer.asUint8List();
      final result = _parseEnvBytes(bytes);
      if (result != null && result.isNotEmpty) {
        print('Successfully loaded .env from assets');
        return result;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading .env from assets: $e');
      }
    }
    return null;
  }

  /// Try loading from file system (web will skip this)
  static Future<Map<String, String>?> _loadEnvFromFile() async {
    if (kIsWeb) return null;

    try {
      final file = File('.env');
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final result = _parseEnvBytes(bytes);
        if (result != null && result.isNotEmpty) {
          print('Successfully loaded .env from file system');
          return result;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading .env from file: $e');
      }
    }
    return null;
  }

  /// Parse bytes into env map, trying different encodings
  static Map<String, String>? _parseEnvBytes(List<int> bytes) {
    if (bytes.isEmpty) return null;

    String content;

    // Try different encodings in sequence
    try {
      content = utf8.decode(bytes);
    } catch (_) {
      try {
        content = latin1.decode(bytes);
      } catch (_) {
        try {
          content = ascii.decode(bytes, allowInvalid: true);
        } catch (e) {
          if (kDebugMode) {
            print('Failed to decode .env with any encoding: $e');
          }
          return null;
        }
      }
    }

    return _parseEnvContent(content);
  }

  /// Parse env content string into a map
  static Map<String, String> _parseEnvContent(String content) {
    final Map<String, String> envMap = {};

    final lines = content.split(RegExp(r'\r?\n'));
    for (var line in lines) {
      line = line.trim();

      // Skip empty lines and comments
      if (line.isEmpty || line.startsWith('#')) continue;

      // Handle lines with = character
      final equalIndex = line.indexOf('=');
      if (equalIndex == -1) continue;

      final key = line.substring(0, equalIndex).trim();
      final value = line.substring(equalIndex + 1).trim();

      // Skip if key is empty
      if (key.isEmpty) continue;

      // Remove quotes if present and handle escaped quotes
      String cleanValue = value;
      if ((cleanValue.startsWith('"') && cleanValue.endsWith('"')) ||
          (cleanValue.startsWith("'") && cleanValue.endsWith("'"))) {
        cleanValue = cleanValue.substring(1, cleanValue.length - 1);
        // Handle escaped quotes
        cleanValue = cleanValue.replaceAll('\\"', '"');
        cleanValue = cleanValue.replaceAll("\\'", "'");
      }

      envMap[key] = cleanValue;
    }

    return envMap;
  }

  /// Validate critical environment variables
  static void _validateEnvVariables(Map<String, String> envMap) {
    final criticalVars = ['API_URL', 'JWT_SECRET'];
    final missing = <String>[];

    for (final varName in criticalVars) {
      if (!envMap.containsKey(varName) || envMap[varName]?.isEmpty == true) {
        missing.add(varName);
      }
    }

    if (missing.isNotEmpty && kDebugMode) {
      print(
        'Warning: Missing critical environment variables: ${missing.join(', ')}',
      );
    }

    // Validate API_URL format
    final apiUrl = envMap['API_URL'];
    if (apiUrl != null && !_isValidUrl(apiUrl)) {
      if (kDebugMode) {
        print('Warning: API_URL seems to be invalid: $apiUrl');
      }
    }
  }

  /// Check if a string is a valid URL
  static bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.hasAuthority || uri.host.isNotEmpty);
    } catch (e) {
      return false;
    }
  }

  /// Provide default environment variables as last resort
  static Map<String, String> _getDefaultEnv() {
    if (kDebugMode) {
      print('Using default environment variables');
    }
    return {
      'API_URL': 'http://localhost:5000/api',
      'PORT': '5000',
      'NODE_ENV': 'development',
      'JWT_SECRET': 'fallback_jwt_secret_for_development_only',
    };
  }

  /// Clear cached env (useful for testing or hot reload)
  static void clearEnvCache() {
    _cachedEnv = null;
  }

  /// Get specific env variable with fallback
  static String getEnvVar(String key, [String? fallback]) {
    return _cachedEnv?[key] ?? fallback ?? '';
  }

  /// Check if running in development mode
  static bool get isDevelopment {
    final nodeEnv = getEnvVar('NODE_ENV', 'development');
    return nodeEnv.toLowerCase() == 'development';
  }

  /// Check if running in production mode
  static bool get isProduction {
    final nodeEnv = getEnvVar('NODE_ENV', 'development');
    return nodeEnv.toLowerCase() == 'production';
  }

  // Existing image loading methods remain the same
  static Future<ImageProvider> loadImage(String path) async {
    try {
      return AssetImage(path);
    } catch (e) {
      return AssetImage(Config.defaultErrorPic);
    }
  }

  static Future<ImageProvider> loadProfilePic(String? path) async {
    if (path == null || path.isEmpty) {
      return AssetImage(Config.defaultProfilePic);
    }
    try {
      return AssetImage(path);
    } catch (e) {
      return AssetImage(Config.defaultProfilePic);
    }
  }

  static Future<ImageProvider> loadGroupPic(String? path) async {
    if (path == null || path.isEmpty) {
      return AssetImage(Config.defaultGroupPic);
    }
    try {
      return AssetImage(path);
    } catch (e) {
      return AssetImage(Config.defaultGroupPic);
    }
  }

  static Future<ImageProvider> loadMessagePic(String? path) async {
    if (path == null || path.isEmpty) {
      return AssetImage(Config.defaultMessagePic);
    }
    try {
      return AssetImage(path);
    } catch (e) {
      return AssetImage(Config.defaultMessagePic);
    }
  }

  static Future<ImageProvider> loadLoadingPic() async {
    try {
      return AssetImage(Config.defaultLoadingPic);
    } catch (e) {
      return AssetImage(Config.defaultErrorPic);
    }
  }

  static Future<ImageProvider> loadErrorPic() async {
    try {
      return AssetImage(Config.defaultErrorPic);
    } catch (e) {
      return const AssetImage('assets/images/fallback_error.png');
    }
  }
}
