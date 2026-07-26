import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forestguard_ikn/main.dart';

void main() {
  testWidgets('Aplikasi ForestGuard harus menampilkan Dashboard', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ForestGuardApp());

    // Verifikasi bahwa judul "Monitoring Realtime" muncul di layar
    expect(find.text('Monitoring Realtime'), findsOneWidget);

    // Verifikasi bahwa Bottom Navigation Bar ada
    expect(find.byType(NavigationBar), findsOneWidget);
    
    // Verifikasi teks 'Dashboard' ada di menu bawah
    expect(find.text('Dashboard'), findsOneWidget);
  });
}