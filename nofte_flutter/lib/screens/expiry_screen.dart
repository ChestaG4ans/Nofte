import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_client.dart';
import '../services/inventory_service.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class ExpiryScreen extends StatefulWidget {
  const ExpiryScreen({super.key});

  @override
  State<ExpiryScreen> createState() => _ExpiryScreenState();
}

class _ExpiryScreenState extends State<ExpiryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<dynamic> _allItems = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInventory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInventory() async {
    setState(() => _isLoading = true);

    try {
      final inventoryService = InventoryService(ApiClient());
      final items = await inventoryService.getInventory();

      if (mounted) {
        setState(() {
          _allItems = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Kedaluwarsa'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Stats Header
          _buildStatsHeader(),
          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textMuted,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'Kritis'),
                Tab(text: 'Segera'),
                Tab(text: 'Segar'),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildItemList(StatusType.critical),
                      _buildItemList(StatusType.soon),
                      _buildItemList(StatusType.fresh),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    final critical = _allItems.where((i) => _getExpiryDays(i) <= 0).length;
    final soon = _allItems.where((i) => _getExpiryDays(i) > 0 && _getExpiryDays(i) <= 3).length;
    final fresh = _allItems.where((i) => _getExpiryDays(i) > 3).length;

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.primary,
      child: Row(
        children: [
          _buildStatBox('$critical', 'Kritis', AppColors.danger),
          const SizedBox(width: 12),
          _buildStatBox('$soon', 'Segera', const Color(0xFFFAC775)),
          const SizedBox(width: 12),
          _buildStatBox('$fresh', 'Segar', AppColors.teal),
        ],
      ),
    );
  }

  Widget _buildStatBox(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xB3FFFFFF)),
            ),
          ],
        ),
      ),
    );
  }

  int _getExpiryDays(dynamic item) {
    if (item is InventoryItem) return item.expiryDays;
    if (item is Map) return (item['expiry_days'] as num?)?.toInt() ?? 0;
    return 0;
  }

  String _getName(dynamic item) {
    if (item is InventoryItem) return item.name;
    if (item is Map) return item['name']?.toString() ?? '-';
    return '-';
  }

  int _getQuantity(dynamic item) {
    if (item is InventoryItem) return item.quantity;
    if (item is Map) return (item['quantity'] as num?)?.toInt() ?? 1;
    return 1;
  }

  String _getUnit(dynamic item) {
    if (item is InventoryItem) return item.unit;
    if (item is Map) return item['unit']?.toString() ?? 'Item';
    return 'Item';
  }

  String _getEmoji(dynamic item) {
    final name = _getName(item).toLowerCase();
    if (name.contains('brokoli')) return '🥦';
    if (name.contains('tomat')) return '🍅';
    if (name.contains('bayam')) return '🥬';
    if (name.contains('apel')) return '🍎';
    if (name.contains('pisang')) return '🍌';
    if (name.contains('telur')) return '🥚';
    if (name.contains('ayam')) return '🍗';
    if (name.contains('ikan')) return '🐟';
    if (name.contains('susu')) return '🥛';
    if (name.contains('keju')) return '🧀';
    if (name.contains('wortel')) return '🥕';
    if (name.contains('bawang')) return '🧅';
    if (name.contains('kentang')) return '🥔';
    return '🥘';
  }

  Widget _buildItemList(StatusType status) {
    List<dynamic> filtered;

    switch (status) {
      case StatusType.critical:
        filtered = _allItems.where((i) => _getExpiryDays(i) <= 0).toList();
        break;
      case StatusType.soon:
        filtered = _allItems.where((i) => _getExpiryDays(i) > 0 && _getExpiryDays(i) <= 3).toList();
        break;
      case StatusType.fresh:
        filtered = _allItems.where((i) => _getExpiryDays(i) > 3).toList();
        break;
      default:
        filtered = [];
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == StatusType.critical
                  ? Icons.check_circle_outline
                  : (status == StatusType.soon ? Icons.access_time : Icons.eco),
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              status == StatusType.critical
                  ? 'Tidak ada bahan kritis!'
                  : (status == StatusType.soon ? 'Tidak ada yang segera' : 'Semua segar!'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              status == StatusType.critical
                  ? 'Tidak ada yang sudah kedaluwarsa'
                  : (status == StatusType.soon ? 'Tidak ada yang perlu segera dipakai' : 'Semua bahan dalam kondisi baik'),
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        return _buildItemCard(item, status);
      },
    );
  }

  Widget _buildItemCard(dynamic item, StatusType status) {
    final days = _getExpiryDays(item);
    final emoji = _getEmoji(item);

    Color statusBg;
    Color statusText;
    String statusLabel;

    switch (status) {
      case StatusType.critical:
        statusBg = AppColors.criticalBg;
        statusText = AppColors.criticalText;
        statusLabel = days == 0 ? 'Hari ini' : 'Kedaluwarsa';
        break;
      case StatusType.soon:
        statusBg = AppColors.soonBg;
        statusText = AppColors.soonText;
        statusLabel = '$days hari';
        break;
      default:
        statusBg = AppColors.freshBg;
        statusText = AppColors.freshText;
        statusLabel = '$days hari';
    }

    return GestureDetector(
      onTap: () => _showItemDetail(context, item, status),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getName(item),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_getQuantity(item)} ${_getUnit(item)}',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusText,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  void _showItemDetail(BuildContext context, dynamic item, StatusType status) {
    final name = _getName(item);
    final quantity = _getQuantity(item);
    final unit = _getUnit(item);
    final days = _getExpiryDays(item);
    final emoji = _getEmoji(item);

    Color statusBg;
    Color statusText;
    String statusLabel;
    String statusDescription;

    switch (status) {
      case StatusType.critical:
        statusBg = AppColors.criticalBg;
        statusText = AppColors.criticalText;
        statusLabel = days == 0 ? 'Hari ini' : 'Kedaluwarsa';
        statusDescription = 'Bahan ini sudah tidak aman untuk dikonsumsi. Sebaiknya segera buang atau olah jika masih bisa.';
        break;
      case StatusType.soon:
        statusBg = AppColors.soonBg;
        statusText = AppColors.soonText;
        statusLabel = '$days hari lagi';
        statusDescription = 'Bahan ini akan segera kedaluwarsa. Gunakan secepatnya untuk menghindari food waste.';
        break;
      default:
        statusBg = AppColors.freshBg;
        statusText = AppColors.freshText;
        statusLabel = '$days hari lagi';
        statusDescription = 'Bahan ini masih segar dan aman untuk dikonsumsi.';
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$quantity $unit',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: statusText,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      status == StatusType.critical
                          ? Icons.warning_amber_rounded
                          : (status == StatusType.soon ? Icons.access_time : Icons.check_circle),
                      color: statusText,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        statusDescription,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Tutup'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Could navigate to recipe screen
                      },
                      icon: const Icon(Icons.restaurant, size: 18),
                      label: const Text('Cari Resep'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
