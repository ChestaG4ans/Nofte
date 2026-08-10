import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          backgroundColor: AppColors.primaryDark,
          body: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => appState.setIndex(0),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Scan Bahan Makanan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Camera View
              Expanded(
                child: Stack(
                  children: [
                    // Background
                    Center(
                      child: Opacity(
                        opacity: 0.08,
                        child: Icon(
                          Icons.kitchen_rounded,
                          size: 200,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Scan Frame
                    Center(
                      child: SizedBox(
                        width: 220,
                        height: 220,
                        child: Stack(
                          children: [
                            // Corner brackets
                            Positioned(
                              top: 0,
                              left: 0,
                              child: _buildCorner(true, true),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: _buildCorner(true, false),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              child: _buildCorner(false, true),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: _buildCorner(false, false),
                            ),
                            // Scanning line
                            if (_isScanning)
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 2500),
                                builder: (context, value, child) {
                                  return Positioned(
                                    top: value * 220,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      height: 2,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            AppColors.teal,
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                onEnd: () {
                                  if (mounted) {
                                    setState(() => _isScanning = false);
                                    _showScanResults(context, appState);
                                  }
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    // Detection Labels
                    Positioned(
                      left: 20,
                      top: 80,
                      child: _buildDetectionLabel('Brokoli 78%', true),
                    ),
                    Positioned(
                      right: 20,
                      top: 150,
                      child: _buildDetectionLabel('Bayam 65%', false),
                    ),
                    // Instruction
                    Positioned(
                      bottom: 60,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          _isScanning ? 'Memindai...' : 'Arahkan ke isi kulkas',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Mode Selection
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.black38,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildModeButton('Kamera', true),
                    const SizedBox(width: 8),
                    _buildModeButton('Galeri', false),
                    const SizedBox(width: 8),
                    _buildModeButton('Manual', false),
                  ],
                ),
              ),
              // Capture Button
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.black38,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() => _isScanning = true);
                      },
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: Colors.white30, width: 3),
                        ),
                        child: Center(
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.teal,
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.flip_camera_ios_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCorner(bool top, bool left) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.teal,
            width: 3,
          ),
          left: BorderSide(
            color: AppColors.teal,
            width: 3,
          ),
        ),
        borderRadius: top
            ? (left ? const BorderRadius.only(topLeft: Radius.circular(4)) : const BorderRadius.only(topRight: Radius.circular(4)))
            : (left ? const BorderRadius.only(bottomLeft: Radius.circular(4)) : const BorderRadius.only(bottomRight: Radius.circular(4))),
      ),
    );
  }

  Widget _buildDetectionLabel(String text, bool isHigh) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }

  void _showScanResults(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Hasil Scan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Diproses 4.2 dtk',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.teal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Stats
                  Row(
                    children: [
                      _buildStatBox('${appState.freshCount}', 'Segar', AppColors.tealDark),
                      const SizedBox(width: 8),
                      _buildStatBox('${appState.soonCount}', 'Segera', const Color(0xFFFAC775)),
                      const SizedBox(width: 8),
                      _buildStatBox('${appState.criticalCount}', 'Kritis', AppColors.danger),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Food List
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        const Text(
                          'BAHAN',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...appState.foodItems.map((item) => _buildFoodItem(item)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            appState.setIndex(2);
                          },
                          child: const Text('Lihat Rekomendasi Resep AI'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatBox(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white12, width: 0.5),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 8.5,
                color: Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodItem(FoodItemUI item) {
    Color statusColor = AppColors.tealDark;
    Color statusBg = AppColors.freshBg;
    String statusLabel = 'Segar';
    double progress = 0.78;

    switch (item.status) {
      case StatusType.fresh:
        statusColor = AppColors.tealDark;
        statusBg = AppColors.freshBg;
        statusLabel = 'Segar';
        progress = 0.78;
      case StatusType.soon:
        statusColor = const Color(0xFFFAC775);
        statusBg = AppColors.soonBg;
        statusLabel = 'Segera';
        progress = 0.40;
      case StatusType.critical:
        statusColor = AppColors.danger;
        statusBg = AppColors.criticalBg;
        statusLabel = 'Kritis';
        progress = 0.10;
      case StatusType.purple:
        statusColor = AppColors.purpleText;
        statusBg = AppColors.purpleBg;
        statusLabel = 'AI';
        progress = 0.60;
      case StatusType.blue:
        statusColor = AppColors.blueText;
        statusBg = AppColors.blueBg;
        statusLabel = 'Info';
        progress = 0.50;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: item.status == StatusType.critical
              ? AppColors.criticalBg
              : AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(item.emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.daysLeft == 0 ? 'Hari ini' : '${item.daysLeft} hari',
                      style: TextStyle(
                        fontSize: 9,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 9),
          StatusPill(label: statusLabel, type: item.status),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? AppColors.teal : Colors.white10,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isActive ? AppColors.primaryDark : Colors.white60,
        ),
      ),
    );
  }
}
