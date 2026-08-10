import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/inventory_service.dart';
import 'services/scan_service.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const NofteApp());
}

class NofteApp extends StatefulWidget {
  const NofteApp({super.key});

  @override
  State<NofteApp> createState() => _NofteAppState();
}

class _NofteAppState extends State<NofteApp> {
  // API Services
  final ApiClient _apiClient = ApiClient();
  late final AuthService _authService;
  late final InventoryService _inventoryService;
  late final ScanService _scanService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(_apiClient);
    _inventoryService = InventoryService(_apiClient);
    _scanService = ScanService(_apiClient);

    // Restore token if exists
    _authService.restoreToken();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        Provider<AuthService>.value(value: _authService),
        Provider<InventoryService>.value(value: _inventoryService),
        Provider<ScanService>.value(value: _scanService),
      ],
      child: MaterialApp(
        title: 'NoFTe',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
