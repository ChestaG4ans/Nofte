import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/models.dart';
import '../services/services.dart';

class ScanScreen extends StatefulWidget {
  final ScanService scanService;
  final InventoryService inventoryService;

  const ScanScreen({
    super.key,
    required this.scanService,
    required this.inventoryService,
  });

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();

  XFile? _image;
  Uint8List? _imageBytes;  // Store image bytes for cross-platform display
  bool _isLoadingImage = false;  // Track image loading state
  List<FoodItem> _foods = [];
  bool _isScanning = false;
  String _statusMessage = 'Ambil foto makanan untuk dipindai';
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Makanan'),
        actions: [
          if (_image != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reset,
              tooltip: 'Reset',
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Preview
              AspectRatio(
                aspectRatio: 3 / 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _isLoadingImage
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 12),
                                Text('Memuat foto...'),
                              ],
                            ),
                          )
                        : _image == null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Belum ada foto',
                                      style: TextStyle(color: Colors.grey[500]),
                                    ),
                                  ],
                                ),
                              )
                            : _buildImageWidget(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Image Source Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoadingImage || _isScanning ? null : () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Kamera'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoadingImage || _isScanning ? null : () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galeri'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Scan Button
              FilledButton.icon(
                onPressed: _image == null || _isScanning || _isLoadingImage ? null : _scan,
                icon: _isScanning
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.search),
                label: Text(_isScanning ? 'Memindai...' : 'Scan Makanan'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 16),

              // Status/Error Message
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Status
              Text(
                _statusMessage,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Results
              if (_foods.isNotEmpty) ...[
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Hasil Scan (${_foods.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ..._foods.asMap().entries.map((entry) {
                  return FoodResultCard(
                    food: entry.value,
                    index: entry.key,
                    onAddToInventory: () => _addToInventory(entry.value),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() => _isLoadingImage = true);

      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (picked != null) {
        // Read image bytes for cross-platform display
        final bytes = await picked.readAsBytes();
        debugPrint('Image picked: ${picked.path}, bytes length: ${bytes.length}');

        if (bytes.isEmpty) {
          setState(() {
            _errorMessage = 'Gambar kosong, coba lagi';
            _isLoadingImage = false;
          });
          return;
        }

        setState(() {
          _image = picked;
          _imageBytes = bytes;
          _foods = [];
          _errorMessage = null;
          _statusMessage = 'Foto siap dipindai';
          _isLoadingImage = false;
        });
      } else {
        setState(() => _isLoadingImage = false);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      setState(() {
        _errorMessage = 'Gagal mengambil foto: $e';
        _isLoadingImage = false;
      });
    }
  }

  /// Build image widget that works on all platforms (mobile & web)
  Widget _buildImageWidget() {
    if (_imageBytes == null) {
      return const Center(child: CircularProgressIndicator());
    }

    debugPrint('Building image widget with ${_imageBytes!.length} bytes');

    return Image.memory(
      _imageBytes!,
      fit: BoxFit.contain,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: child,
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Image error: $error');
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text('Gagal memuat foto', style: TextStyle(color: Colors.grey[500])),
              const SizedBox(height: 4),
              Text(
                'Error: $error',
                style: TextStyle(color: Colors.grey[400], fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _scan() async {
    if (_image == null) return;

    setState(() {
      _isScanning = true;
      _errorMessage = null;
      _statusMessage = 'Memindai...';
      _foods = [];
    });

    try {
      final foods = await widget.scanService.scanImage(_image!);
      setState(() {
        _foods = foods;
        _statusMessage = foods.isEmpty
            ? 'Tidak ada makanan terdeteksi'
            : 'Ditemukan ${foods.length} makanan';
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _statusMessage = 'Scan gagal';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
        _statusMessage = 'Scan gagal';
      });
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  Future<void> _addToInventory(FoodItem food) async {
    try {
      await widget.inventoryService.addFromScan(
        name: food.name,
        expiryDays: food.shelfLife,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${food.name} ditambahkan ke inventory'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: ${e.message}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _reset() {
    setState(() {
      _image = null;
      _imageBytes = null;
      _foods = [];
      _errorMessage = null;
      _isLoadingImage = false;
      _statusMessage = 'Ambil foto makanan untuk dipindai';
    });
  }
}

class FoodResultCard extends StatelessWidget {
  final FoodItem food;
  final int index;
  final VoidCallback onAddToInventory;

  const FoodResultCard({
    super.key,
    required this.food,
    required this.index,
    required this.onAddToInventory,
  });

  Color get _freshnessColor {
    switch (food.freshness.toLowerCase()) {
      case 'segar':
        return Colors.green;
      case 'perlu dicek':
        return Colors.orange;
      case 'tidak segar':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get _freshnessEmoji {
    switch (food.freshness.toLowerCase()) {
      case 'segar':
        return '✅';
      case 'perlu dicek':
        return '⚠️';
      case 'tidak segar':
        return '❌';
      default:
        return '❓';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _freshnessColor.withValues(alpha: 0.2),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: _freshnessColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Row(
                        children: [
                          Text(_freshnessEmoji),
                          const SizedBox(width: 4),
                          Text(
                            food.freshness,
                            style: TextStyle(color: _freshnessColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (food.confidence != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(food.confidence! * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Info Grid
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.timer_outlined,
                    label: 'Daya Simpan',
                    value: '${food.shelfLife} hari',
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    icon: Icons.source_outlined,
                    label: 'Sumber',
                    value: food.decisionSource ?? '-',
                  ),
                ),
              ],
            ),

            // Nutrition Info
            if (food.nutrition != null) ...[
              const SizedBox(height: 12),
              ExpansionTile(
                title: const Text('Info Nutrisi'),
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(top: 8),
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (food.nutrition!.calories != null)
                        _NutritionChip(
                          label: 'Kalori',
                          value: '${food.nutrition!.calories!.toStringAsFixed(0)} kcal',
                        ),
                      if (food.nutrition!.proteinG != null)
                        _NutritionChip(
                          label: 'Protein',
                          value: '${food.nutrition!.proteinG!.toStringAsFixed(1)}g',
                        ),
                      if (food.nutrition!.carbohydratesG != null)
                        _NutritionChip(
                          label: 'Karbo',
                          value: '${food.nutrition!.carbohydratesG!.toStringAsFixed(1)}g',
                        ),
                      if (food.nutrition!.fiberG != null)
                        _NutritionChip(
                          label: 'Serat',
                          value: '${food.nutrition!.fiberG!.toStringAsFixed(1)}g',
                        ),
                    ],
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),

            // Add to Inventory Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAddToInventory,
                icon: const Icon(Icons.add_shopping_cart),
                label: Text('Tambah ke Inventory (${food.shelfLife} hari)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green[700],
                  side: BorderSide(color: Colors.green[700]!),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NutritionChip extends StatelessWidget {
  final String label;
  final String value;

  const _NutritionChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
