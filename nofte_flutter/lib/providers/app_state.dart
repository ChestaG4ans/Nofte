import 'package:flutter/material.dart';
import '../models/models.dart';

/// Status Type for food freshness
enum StatusType { fresh, soon, critical, purple, blue }

/// App State Provider
class AppState extends ChangeNotifier {
  // Navigation
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  // User
  String _userName = 'User';
  String get userName => _userName;

  // Kitchen Score
  final int _kitchenScore = 72;
  int get kitchenScore => _kitchenScore;

  final double _weeklyChange = 5;
  double get weeklyChange => _weeklyChange;

  // Food Items (from backend)
  List<FoodItemUI> _foodItems = [];
  List<FoodItemUI> get foodItems => _foodItems;

  // Scan Results
  int get freshCount => _foodItems.where((f) => f.status == StatusType.fresh).length;
  int get soonCount => _foodItems.where((f) => f.status == StatusType.soon).length;
  int get criticalCount => _foodItems.where((f) => f.status == StatusType.critical).length;

  // Recipes
  final List<Recipe> _recipes = [
    Recipe(
      name: 'Tumis Bayam Bawang Putih',
      time: 15,
      servings: 2,
      calories: 142,
      ingredients: ['Bayam 200g', 'Bawang putih 3 siung'],
      tags: ['AI Pick', 'Gunakan Bayam!'],
      isAiPick: true,
    ),
    Recipe(
      name: 'Omelet Tomat Brokoli',
      time: 12,
      servings: 1,
      calories: 280,
      ingredients: ['Telur 2 butir', 'Tomat 1 buah', 'Brokoli 100g'],
      tags: ['Sarapan', 'Cepat'],
    ),
    Recipe(
      name: 'Tumis Brokoli Telur Pedas',
      time: 20,
      servings: 2,
      calories: 180,
      ingredients: ['Brokoli 150g', 'Telur 2 butir'],
      tags: ['Pakai bahan ada', 'AI Pick'],
      isAiPick: true,
    ),
  ];
  List<Recipe> get recipes => _recipes;

  // Notifications
  int _notificationCount = 0;
  int get notificationCount => _notificationCount;

  // Notification Settings
  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  bool _recipeNotifications = true;
  bool get recipeNotifications => _recipeNotifications;

  bool _scanNotifications = false;
  bool get scanNotifications => _scanNotifications;

  // Theme
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  // Onboarding
  bool _hasCompletedOnboarding = false;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  // Methods
  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
  }

  void toggleRecipeNotifications() {
    _recipeNotifications = !_recipeNotifications;
    notifyListeners();
  }

  void toggleScanNotifications() {
    _scanNotifications = !_scanNotifications;
    notifyListeners();
  }

  void completeOnboarding() {
    _hasCompletedOnboarding = true;
    notifyListeners();
  }

  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  /// Update food items from backend inventory
  void updateFoodItems(List<InventoryItem> items) {
    _foodItems = items.map((item) {
      StatusType status;
      if (item.expiryDays <= 0) {
        status = StatusType.critical;
      } else if (item.expiryDays <= 3) {
        status = StatusType.critical;
      } else if (item.expiryDays <= 7) {
        status = StatusType.soon;
      } else {
        status = StatusType.fresh;
      }

      // Map name to emoji
      String emoji = _getEmoji(item.name);

      return FoodItemUI(
        name: item.name,
        emoji: emoji,
        daysLeft: item.expiryDays,
        status: status,
      );
    }).toList();

    // Update notification count
    _notificationCount = _foodItems
        .where((f) => f.status == StatusType.soon || f.status == StatusType.critical)
        .length;

    notifyListeners();
  }

  String _getEmoji(String name) {
    final n = name.toLowerCase();
    if (n.contains('brokoli') || n.contains('broccoli')) return '🥦';
    if (n.contains('tomat') || n.contains('tomato')) return '🍅';
    if (n.contains('bayam') || n.contains('spinach')) return '🥬';
    if (n.contains('apel') || n.contains('apple')) return '🍎';
    if (n.contains('pisang') || n.contains('banana')) return '🍌';
    if (n.contains('telur') || n.contains('egg')) return '🥚';
    if (n.contains('ayam') || n.contains('chicken')) return '🍗';
    if (n.contains('ikan') || n.contains('fish')) return '🐟';
    if (n.contains('nasi') || n.contains('rice')) return '🍚';
    if (n.contains('roti') || n.contains('bread')) return '🍞';
    if (n.contains('susu') || n.contains('milk')) return '🥛';
    if (n.contains('keju') || n.contains('cheese')) return '🧀';
    if (n.contains('wortel') || n.contains('carrot')) return '🥕';
    if (n.contains('bawang') || n.contains('onion')) return '🧅';
    if (n.contains('kentang') || n.contains('potato')) return '🥔';
    if (n.contains('buncis')) return '🫘';
    if (n.contains('kol') || n.contains('cabbage')) return '🥗';
    if (n.contains('selada') || n.contains('lettuce')) return '🥬';
    if (n.contains('mentimun') || n.contains('cucumber')) return '🥒';
    return '🥘';
  }

  void clearNotifications() {
    _notificationCount = 0;
    notifyListeners();
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }
}

/// Food Item UI Model (for display)
class FoodItemUI {
  final String name;
  final String emoji;
  final int daysLeft;
  final StatusType status;

  FoodItemUI({
    required this.name,
    required this.emoji,
    required this.daysLeft,
    required this.status,
  });
}

/// Recipe Model
class Recipe {
  final String name;
  final int time;
  final int servings;
  final int calories;
  final List<String> ingredients;
  final List<String> tags;
  final bool isAiPick;

  Recipe({
    required this.name,
    required this.time,
    required this.servings,
    required this.calories,
    required this.ingredients,
    required this.tags,
    this.isAiPick = false,
  });
}
