import '../config/api_config.dart';
import '../models/models.dart';
import 'api_client.dart';

/// Service for history operations
class HistoryService {
  final ApiClient _api;

  HistoryService(this._api);

  Future<List<HistoryItem>> getHistory() async {
    final result = await _api.get(ApiConfig.history);
    if (result == null) return [];

    final list = result as List<dynamic>;
    return list
        .map((item) => HistoryItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
