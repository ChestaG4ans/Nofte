import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/inventory_service.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'history_screen.dart';
import 'expiry_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final inventoryService = Provider.of<InventoryService>(context, listen: false);
      final items = await inventoryService.getInventory();

      if (mounted) {
        final appState = Provider.of<AppState>(context, listen: false);
        appState.updateFoodItems(items);
        setState(() => _isLoading = false);
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat data';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: RefreshIndicator(
            onRefresh: _loadInventory,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(context, appState),
                ),
                SliverToBoxAdapter(
                  child: _buildQuickActions(context, appState),
                ),
                SliverToBoxAdapter(
                  child: _buildSectionHeader('Bahan di Kulkas', onSeeAll: () {}),
                ),
                if (_isLoading)
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  )
                else if (_error != null)
                  SliverToBoxAdapter(
                    child: _buildErrorWidget(),
                  )
                else
                  SliverToBoxAdapter(
                    child: _buildFoodItemsList(appState),
                  ),
                SliverToBoxAdapter(
                  child: _buildScanBanner(context, appState),
                ),
                SliverToBoxAdapter(
                  child: _buildSectionHeader('Rekomendasi Resep', onSeeAll: () => appState.setIndex(2)),
                ),
                SliverToBoxAdapter(
                  child: _buildRecipeCard(context, appState),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.criticalBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppColors.criticalText, size: 40),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Terjadi kesalahan',
            style: TextStyle(color: AppColors.criticalText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loadInventory,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.criticalText,
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppState appState) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF154360)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Noftelogo(size: 28, variant: 'teal'),
                      const SizedBox(width: 8),
                      const Text(
                        'NoFTe',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _showNotifications(context, appState),
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              child: const Icon(Icons.notifications_outlined, color: Colors.white70, size: 22),
                            ),
                            if (appState.notificationCount > 0)
                              Positioned(
                                right: 4,
                                top: 4,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.danger,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColors.primary, width: 1.5),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => appState.setIndex(3),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.teal,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              'AP',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                '${appState.getGreeting()}, ${appState.userName}',
                style: const TextStyle(fontSize: 11, color: Color(0xA6FFFFFF)),
              ),
              const SizedBox(height: 2),
              const Text(
                'Kelola dapurmu hari ini',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),
              ScoreCard(
                score: appState.kitchenScore,
                change: appState.weeklyChange,
                subtitle: 'Kamu menghemat 2,1 kg makanan bulan ini',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppState appState) {
    return Transform.translate(
      offset: const Offset(0, -14),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            QuickActionButton(
              icon: Icons.camera_alt_rounded,
              label: 'Scan',
              bgColor: AppColors.freshBg,
              iconColor: AppColors.freshText,
              onTap: () => appState.setIndex(1),
            ),
            QuickActionButton(
              icon: Icons.history_rounded,
              label: 'Riwayat',
              bgColor: AppColors.blueBg,
              iconColor: AppColors.blueText,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryScreen()),
                );
              },
            ),
            QuickActionButton(
              icon: Icons.access_time_rounded,
              label: 'Kedaluwarsa',
              bgColor: AppColors.soonBg,
              iconColor: AppColors.soonText,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExpiryScreen()),
                );
              },
            ),
            QuickActionButton(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'AI Chat',
              bgColor: AppColors.purpleBg,
              iconColor: AppColors.purpleText,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(13, 16, 13, 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              'Lihat semua',
              style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItemsList(AppState appState) {
    if (appState.foodItems.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.kitchen_outlined, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              'Belum ada bahan makanan',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan kulkas untuk menambahkan',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: appState.foodItems.length,
        itemBuilder: (context, index) {
          final item = appState.foodItems[index];
          return Container(
            width: 76,
            margin: const EdgeInsets.only(right: 8),
            child: FoodItemCard(
              name: item.name,
              emoji: item.emoji,
              daysLeft: item.daysLeft,
              status: item.status,
            ),
          );
        },
      ),
    );
  }

  Widget _buildScanBanner(BuildContext context, AppState appState) {
    return GestureDetector(
      onTap: () => appState.setIndex(1),
      child: Container(
        margin: const EdgeInsets.all(11),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            const Noftelogo(size: 32),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Scan kulkas sekarang',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  SizedBox(height: 1),
                  Text(
                    'AI NoFTe siap dalam 5 detik',
                    style: TextStyle(fontSize: 9, color: Colors.white54),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.teal,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Text(
                'Scan',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, AppState appState) {
    return GestureDetector(
      onTap: () => appState.setIndex(2),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 11),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.freshBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Text('🥭', style: TextStyle(fontSize: 20))),
            ),
            SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tumis Brokoli Telur Pedas',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 1),
                  const Text(
                    '20 mnt 2 porsi',
                    style: TextStyle(fontSize: 9, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  const Wrap(
                    spacing: 3,
                    children: [
                      StatusPill(label: 'Pakai bahan ada', type: StatusType.fresh),
                      StatusPill(label: 'AI Pick', type: StatusType.purple),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.favorite_border, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final expiringItems = appState.foodItems
            .where((f) => f.status == StatusType.soon || f.status == StatusType.critical)
            .toList();
        return Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Peringatan Kadaluarsa',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${appState.notificationCount}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: expiringItems.isEmpty
                    ? const Center(
                        child: Text(
                          'Semua makanan masih segar!',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        itemCount: expiringItems.length,
                        itemBuilder: (context, index) {
                          final item = expiringItems[index];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Text(item.emoji, style: const TextStyle(fontSize: 24)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                                      ),
                                      Text(
                                        item.daysLeft == 0 ? 'Hari ini' : '${item.daysLeft} hari lagi',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: item.status == StatusType.critical
                                              ? AppColors.criticalText
                                              : AppColors.soonText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  item.daysLeft == 0 ? 'Hari ini' : '${item.daysLeft}d',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: item.status == StatusType.critical
                                        ? AppColors.criticalText
                                        : AppColors.soonText,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
