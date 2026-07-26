import '../config/api_config.dart';
import '../models/models.dart';
import 'api_client.dart';

/// Service for inventory operations
class InventoryService {
  final ApiClient _api;

  InventoryService(this._api);

  Future<List<InventoryItem>> getInventory() async {
    final result = await _api.get(ApiConfig.inventory);
    if (result == null) return [];

    final list = result as List<dynamic>;
    return list
        .map((item) => InventoryItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<InventoryItem> addInventory(InventoryItem item) async {
    final data = await _api.post(ApiConfig.inventory, item.toJson())
        as Map<String, dynamic>;
    return InventoryItem.fromJson(data);
  }

  Future<InventoryItem> addFromScan({
    required String name,
    required int expiryDays,
    int quantity = 1,
    String unit = 'Item',
  }) async {
    final data = await _api.post(ApiConfig.inventoryFromScan, {
      'name': name,
      'expiry_days': expiryDays,
      'quantity': quantity,
      'unit': unit,
    }) as Map<String, dynamic>;
    return InventoryItem.fromJson(data);
  }

  Future<void> deleteItem(int itemId) async {
    await _api.delete('${ApiConfig.inventory}/$itemId');
  }
}
