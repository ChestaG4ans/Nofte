import 'package:image_picker/image_picker.dart';

import '../config/api_config.dart';
import '../models/models.dart';
import 'api_client.dart';

/// Service for scan operations
class ScanService {
  final ApiClient _api;

  ScanService(this._api);

  Future<List<FoodItem>> scanImage(XFile image) async {
    final bytes = await image.readAsBytes();
    final result = await _api.postBytes(
      ApiConfig.scan,
      bytes,
      contentType: image.mimeType ?? 'image/jpeg',
    ) as Map<String, dynamic>;

    final foodsJson = result['foods'] as List<dynamic>? ?? [];
    return foodsJson
        .map((item) => FoodItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
