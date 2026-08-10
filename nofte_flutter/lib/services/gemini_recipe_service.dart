import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/models.dart';

/// Service for AI Recipe suggestions using Gemini API
class GeminiRecipeService {
  final http.Client _client;

  GeminiRecipeService({http.Client? client}) : _client = client ?? http.Client();

  /// Get recipe suggestions based on available inventory ingredients
  Future<List<GeminiRecipe>> getRecipeSuggestions({
    required List<InventoryItem> inventory,
    int maxRecipes = 5,
  }) async {
    try {
      // Extract ingredient names from inventory
      final ingredients = inventory.map((item) => item.name).toList();

      if (ingredients.isEmpty) {
        return _getDefaultRecipes();
      }

      // Build the prompt for Gemini
      final ingredientList = ingredients.join(', ');
      final prompt = '''
Kamu adalah chef profesional Indonesia. Berdasarkan bahan-bahan berikut yang tersedia di kulkas: $ingredientList

Buatkan $maxRecipes resep makanan Indonesia yang bisa dibuat dengan bahan-bahan tersebut.

FORMAT RESPONSE (WAJIB JSON):
[
  {
    "name": "Nama Resep",
    "time_minutes": 15,
    "servings": 2,
    "calories": 150,
    "ingredients": ["Bahan 1", "Bahan 2"],
    "instructions": ["Langkah 1", "Langkah 2"],
    "tags": ["Mudah", "Cepat"]
  }
]

HANYA KEMBALIKAN JSON ARRAY, TANPA TEXT LAIN.
''';

      final response = await _client.post(
        Uri.parse('${ApiConfig.geminiBaseUrl}?key=${ApiConfig.geminiApiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 2048,
          }
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';

        // Parse the JSON response
        return _parseRecipes(text, inventory);
      } else {
        // Fallback to default recipes
        return _getDefaultRecipes();
      }
    } catch (e) {
      // On error, return default recipes
      return _getDefaultRecipes();
    }
  }

  /// Get recipe suggestion for specific ingredient
  Future<String> getRecipeForIngredient(String ingredient) async {
    try {
      final prompt = '''
Kamu adalah chef profesional Indonesia. Berikan 1 resep cepat dengan $ingredient sebagai bahan utama.

FORMAT RESPONSE (WAJIB JSON):
{
  "name": "Nama Resep",
  "time_minutes": 15,
  "servings": 2,
  "calories": 150,
  "ingredients": ["Bahan 1", "Bahan 2"],
  "instructions": ["Langkah 1", "Langkah 2"]
}

HANYA KEMBALIKAN JSON, TANPA TEXT LAIN.
''';

      final response = await _client.post(
        Uri.parse('${ApiConfig.geminiBaseUrl}?key=${ApiConfig.geminiApiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1024,
          }
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
        return text;
      } else {
        return _getDefaultRecipeText(ingredient);
      }
    } catch (e) {
      return _getDefaultRecipeText(ingredient);
    }
  }

  /// Check what ingredients are available for a recipe
  Future<Map<String, bool>> checkAvailableIngredients({
    required List<String> recipeIngredients,
    required List<InventoryItem> inventory,
  }) async {
    final inventoryNames = inventory.map((i) => i.name.toLowerCase()).toSet();

    final result = <String, bool>{};
    for (final ingredient in recipeIngredients) {
      final isAvailable = inventoryNames.any((inv) =>
        ingredient.toLowerCase().contains(inv) ||
        inv.contains(ingredient.toLowerCase())
      );
      result[ingredient] = isAvailable;
    }
    return result;
  }

  List<GeminiRecipe> _parseRecipes(String text, List<InventoryItem> inventory) {
    try {
      // Clean the text - remove markdown code blocks if present
      var cleanText = text.trim();
      if (cleanText.startsWith('```json')) {
        cleanText = cleanText.substring(7);
      } else if (cleanText.startsWith('```')) {
        cleanText = cleanText.substring(3);
      }
      if (cleanText.endsWith('```')) {
        cleanText = cleanText.substring(0, cleanText.length - 3);
      }
      cleanText = cleanText.trim();

      final List<dynamic> jsonList = jsonDecode(cleanText);
      return jsonList.map((json) => GeminiRecipe.fromJson(json, inventory)).toList();
    } catch (e) {
      return _getDefaultRecipes();
    }
  }

  List<GeminiRecipe> _getDefaultRecipes() {
    return [
      GeminiRecipe(
        name: 'Tumis Bayam Bawang Putih',
        timeMinutes: 15,
        servings: 2,
        calories: 142,
        ingredients: ['Bayam 200g', 'Bawang putih 3 siung', 'Minyak goreng 2 sdm'],
        instructions: ['Cuci bayam hingga bersih', 'Tumis bawang putih hingga harum', 'Masukkan bayam, masak 5 menit', 'Tambahkan garam secukupnya'],
        tags: ['Mudah', 'Sehat', 'Vegetarian'],
        isAiPick: true,
      ),
      GeminiRecipe(
        name: 'Omelet Sayuran',
        timeMinutes: 10,
        servings: 1,
        calories: 200,
        ingredients: ['Telur 2 butir', 'Wortel 1/2 buah', 'Buncis 3 batang'],
        instructions: ['Kocok telur dengan garam', 'Potong kecil sayuran', 'Tumis sayuran sebentar', 'Masukkan telur, masak hingga matang'],
        tags: ['Cepat', 'Protein'],
        isAiPick: true,
      ),
      GeminiRecipe(
        name: 'Soto Ayam Simple',
        timeMinutes: 30,
        servings: 4,
        calories: 320,
        ingredients: ['Ayam 500g', 'Bihun 100g', 'Bawang goreng'],
        instructions: ['Rebus ayam hingga matang', 'Saring kuah', 'Masukkan bihun', 'Sajikan dengan bawang goreng'],
        tags: ['Indonesia', 'Berkuah'],
        isAiPick: false,
      ),
    ];
  }

  String _getDefaultRecipeText(String ingredient) {
    return '''
{
  "name": "Tumis $ingredient",
  "time_minutes": 15,
  "servings": 2,
  "calories": 150,
  "ingredients": ["$ingredient 200g", "Bawang putih 2 siung", "Minyak goreng"],
  "instructions": ["Tumis bawang putih", "Masukkan $ingredient", "Masak 10 menit", "Sajikan"]
}
''';
  }
}

/// Model for Gemini Recipe Response
class GeminiRecipe {
  final String name;
  final int timeMinutes;
  final int servings;
  final int calories;
  final List<String> ingredients;
  final List<String> instructions;
  final List<String> tags;
  final bool isAiPick;
  final Map<String, bool>? availableIngredients;

  GeminiRecipe({
    required this.name,
    required this.timeMinutes,
    required this.servings,
    required this.calories,
    required this.ingredients,
    required this.instructions,
    required this.tags,
    this.isAiPick = false,
    this.availableIngredients,
  });

  factory GeminiRecipe.fromJson(Map<String, dynamic> json, List<InventoryItem> inventory) {
    final ingredients = (json['ingredients'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ?? [];

    // Check which ingredients are available
    final inventoryNames = inventory.map((i) => i.name.toLowerCase()).toSet();
    final available = <String, bool>{};
    for (final ing in ingredients) {
      available[ing] = inventoryNames.any((inv) =>
        ing.toLowerCase().contains(inv) || inv.contains(ing.toLowerCase())
      );
    }

    return GeminiRecipe(
      name: json['name']?.toString() ?? 'Resep Tanpa Nama',
      timeMinutes: (json['time_minutes'] as num?)?.toInt() ?? 15,
      servings: (json['servings'] as num?)?.toInt() ?? 2,
      calories: (json['calories'] as num?)?.toInt() ?? 150,
      ingredients: ingredients,
      instructions: (json['instructions'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      isAiPick: true,
      availableIngredients: available,
    );
  }

  int get availableCount => availableIngredients?.values.where((v) => v).length ?? 0;
  bool get canMake => availableCount == ingredients.length;
}
