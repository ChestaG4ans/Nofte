import 'package:flutter/material.dart';

import 'config/api_config.dart';
import 'screens/screens.dart';
import 'services/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiConfig.load();
  runApp(const NofteApp());
}

class NofteApp extends StatefulWidget {
  const NofteApp({super.key});

  @override
  State<NofteApp> createState() => _NofteAppState();
}

class _NofteAppState extends State<NofteApp> {
  late final ApiClient _apiClient;
  late final AuthService _authService;
  late final ScanService _scanService;
  late final InventoryService _inventoryService;
  late final HistoryService _historyService;

  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  void _initServices() {
    _apiClient = ApiClient();
    _authService = AuthService(_apiClient);
    _scanService = ScanService(_apiClient);
    _inventoryService = InventoryService(_apiClient);
    _historyService = HistoryService(_apiClient);
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await _authService.restoreToken();
    try {
      await _authService.me();
      setState(() {
        _isLoggedIn = true;
        _isLoading = false;
      });
    } catch (_) {
      await _authService.clearToken();
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _onLoginSuccess() async {
    setState(() => _isLoggedIn = true);
  }

  Future<void> _onLogout() async {
    await _authService.logout();
    setState(() => _isLoggedIn = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoFTe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1F7A5B),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: _isLoading
          ? const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.eco, size: 64, color: Color(0xFF1F7A5B)),
                    SizedBox(height: 16),
                    Text(
                      'NoFTe',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F7A5B),
                      ),
                    ),
                    SizedBox(height: 24),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            )
          : _isLoggedIn
              ? HomeScreen(
                  authService: _authService,
                  scanService: _scanService,
                  inventoryService: _inventoryService,
                  historyService: _historyService,
                  onLogout: _onLogout,
                )
              : LoginScreen(
                  authService: _authService,
                  onLoginSuccess: _onLoginSuccess,
                ),
    );
  }
}