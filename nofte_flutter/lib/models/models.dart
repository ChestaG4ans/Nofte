class FoodItem {
  final String name;
  final String freshness;
  final int shelfLife;
  final double? confidence;
  final String? detectedLabel;
  final String? yoloLabel;
  final double? yoloConfidence;
  final String? decisionSource;
  final BoundingBox? bbox;
  final NutritionInfo? nutrition;

  const FoodItem({
    required this.name,
    required this.freshness,
    required this.shelfLife,
    this.confidence,
    this.detectedLabel,
    this.yoloLabel,
    this.yoloConfidence,
    this.decisionSource,
    this.bbox,
    this.nutrition,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name']?.toString() ?? 'Unknown',
      freshness: json['freshness']?.toString() ?? '-',
      shelfLife: (json['shelf_life'] as num?)?.toInt() ?? 0,
      confidence: _parseDouble(json['confidence']),
      detectedLabel: json['detected_label']?.toString(),
      yoloLabel: json['yolo_label']?.toString(),
      yoloConfidence: _parseDouble(json['yolo_confidence']),
      decisionSource: json['decision_source']?.toString(),
      bbox: json['bbox'] == null
          ? null
          : BoundingBox.fromJson(json['bbox'] as Map<String, dynamic>),
      nutrition: json['nutrition'] == null
          ? null
          : NutritionInfo.fromJson(json['nutrition'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'freshness': freshness,
        'shelf_life': shelfLife,
        'confidence': confidence,
        'detected_label': detectedLabel,
        'yolo_label': yoloLabel,
        'yolo_confidence': yoloConfidence,
        'decision_source': decisionSource,
        'bbox': bbox?.toJson(),
        'nutrition': nutrition?.toJson(),
      };
}

class BoundingBox {
  final double x1;
  final double y1;
  final double x2;
  final double y2;

  const BoundingBox({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });

  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    return BoundingBox(
      x1: _parseDouble(json['x1']) ?? 0,
      y1: _parseDouble(json['y1']) ?? 0,
      x2: _parseDouble(json['x2']) ?? 0,
      y2: _parseDouble(json['y2']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'x1': x1,
        'y1': y1,
        'x2': x2,
        'y2': y2,
      };
}

class NutritionInfo {
  final String? serving;
  final double? calories;
  final double? totalFatG;
  final double? sodiumMg;
  final double? potassiumMg;
  final double? carbohydratesG;
  final double? fiberG;
  final double? sugarsG;
  final double? proteinG;

  const NutritionInfo({
    this.serving,
    this.calories,
    this.totalFatG,
    this.sodiumMg,
    this.potassiumMg,
    this.carbohydratesG,
    this.fiberG,
    this.sugarsG,
    this.proteinG,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      serving: json['serving']?.toString(),
      calories: _parseDouble(json['calories']),
      totalFatG: _parseDouble(json['total_fat_g']),
      sodiumMg: _parseDouble(json['sodium_mg']),
      potassiumMg: _parseDouble(json['potassium_mg']),
      carbohydratesG: _parseDouble(json['carbohydrates_g']),
      fiberG: _parseDouble(json['fiber_g']),
      sugarsG: _parseDouble(json['sugars_g']),
      proteinG: _parseDouble(json['protein_g']),
    );
  }

  Map<String, dynamic> toJson() => {
        'serving': serving,
        'calories': calories,
        'total_fat_g': totalFatG,
        'sodium_mg': sodiumMg,
        'potassium_mg': potassiumMg,
        'carbohydrates_g': carbohydratesG,
        'fiber_g': fiberG,
        'sugars_g': sugarsG,
        'protein_g': proteinG,
      };
}

class HistoryItem {
  final int id;
  final int userId;
  final String scanResult;
  final DateTime createdAt;

  const HistoryItem({
    required this.id,
    required this.userId,
    required this.scanResult,
    required this.createdAt,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      scanResult: json['scan_result']?.toString() ?? '-',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class InventoryItem {
  final int id;
  final int userId;
  final String name;
  final int quantity;
  final String unit;
  final int expiryDays;
  final DateTime? expiryDate;
  final DateTime createdAt;

  const InventoryItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.expiryDays,
    this.expiryDate,
    required this.createdAt,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '-',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unit: json['unit']?.toString() ?? 'Item',
      expiryDays: (json['expiry_days'] as num?)?.toInt() ?? 0,
      expiryDate: json['expiry_date'] != null
          ? DateTime.tryParse(json['expiry_date'].toString())
          : null,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'expiry_days': expiryDays,
      };
}

class User {
  final int id;
  final String? name;
  final String email;

  const User({
    required this.id,
    this.name,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString(),
      email: json['email']?.toString() ?? '-',
    );
  }
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
