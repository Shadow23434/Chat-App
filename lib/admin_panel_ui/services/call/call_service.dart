import 'package:chat_app/core/models/call_model.dart';
import 'package:chat_app/admin_panel_ui/services/base/base_service.dart';

class CallService extends BaseService {
  Future<Map<String, dynamic>> getCalls({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String sort = 'desc',
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'sort': sort,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (status != null && status.isNotEmpty && status != 'All') {
        queryParams['status'] = status.toLowerCase();
      }

      final response = await dio.get('/calls', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data == null || data is! Map<String, dynamic>) {
          throw Exception('Invalid response data format');
        }
        if (!data.containsKey('calls') ||
            !data.containsKey('pagination') ||
            data['calls'] == null ||
            data['pagination'] == null) {
          throw Exception('Missing data in response: calls or pagination');
        }
        final List<dynamic> callsJson = data['calls'];
        final paginationData = data['pagination'];

        return {
          'calls': callsJson.map((json) => CallModel.fromJson(json)).toList(),
          'pagination': paginationData,
        };
      } else {
        throw Exception('Failed to load calls: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error getting calls: $e');
    }
  }

  Future<void> deleteCall(String callId) async {
    try {
      final response = await dio.post('/calls/delete/$callId');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete call: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error deleting call: $e');
    }
  }
}
