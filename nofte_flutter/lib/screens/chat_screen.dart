import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

/// AI Assistant Chat Screen
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add({
      'role': 'ai',
      'text': 'Halo! 👋\n\nSaya AI Assistant NoFTe.\n\nTanyakan apa saja tentang:\n• Tips menyimpan makanan\n• Resep memasak bahan segar\n• Cara mengurangi food waste\n• Info nutrisi makanan',
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isLoading = true;
    });

    _controller.clear();

    // Simulate AI response for demo
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        String response = _generateResponse(text);
        setState(() {
          _messages.add({'role': 'ai', 'text': response});
          _isLoading = false;
        });
      }
    });
  }

  String _generateResponse(String question) {
    final q = question.toLowerCase();
    if (q.contains('resep') || q.contains('masak')) {
      return '🍳 Berikut beberapa resep yang bisa Anda coba:\n\n• Tumis Bayam Bawang Putih - 15 menit\n• Omelet Sayuran - 10 menit\n• Soto Ayam Simple - 30 menit\n\nKetuk menu Resep untuk rekomendasi lengkap!';
    } else if (q.contains('simpan') || q.contains('tempat')) {
      return '💡 Tips menyimpan makanan:\n\n• Sayuran hijau → Simpan di kulkas dengan tisu basah\n• Tomat → Simpan di suhu ruang, jangan di kulkas\n• Telur → Simpan di kulkas bagian bawah\n• Roti → Simpan di tempat sejuk';
    } else if (q.contains('kadaluwarsa') || q.contains('expired')) {
      return '⏰ Penting untuk cek tanggal kadaluwarsa!\n\nBahan yang sudah kedaluwarsa:\n• Bisa menyebabkan keracunan makanan\n• Nutrisi berkurang drastis\n• Sereal: 6-12 bulan\n• Susu: 1 minggu setelah expired\n• Telur: 3-5 minggu';
    } else if (q.contains('food waste') || q.contains('buang')) {
      return '🌍 Tips mengurangi food waste:\n\n• Belanja sesuai kebutuhan\n• Gunakan freezer untuk menyimpan lebih lama\n• Olah sisa makanan jadi menu baru\n• Buat daftar belanja sebelum shopping\n• Cek kulkas sebelum beli bahan baru';
    }
    return '🤔 Saya akan bantu pertanyaan Anda!\n\nCoba tanyakan tentang:\n• Resep masakan\n• Tips menyimpan makanan\n• Info kadaluwarsa\n• Cara mengurangi food waste';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            title: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.teal,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.smart_toy_outlined, size: 16, color: AppColors.primaryDark),
                ),
                const SizedBox(width: 10),
                const Text('AI Chat'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    _messages.clear();
                    _messages.add({
                      'role': 'ai',
                      'text': 'Halo! 👋\n\nSaya AI Assistant NoFTe. Ada yang bisa saya bantu?\n\nTopik:\n• Tips menyimpan makanan\n• Resep memasak\n• Food waste\n• Info nutrisi',
                    });
                  });
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isUser = msg['role'] == 'user';

                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.78,
                        ),
                        decoration: BoxDecoration(
                          color: isUser
                              ? AppColors.primary
                              : AppColors.surface,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isUser ? 16 : 4),
                            bottomRight: Radius.circular(isUser ? 4 : 16),
                          ),
                          border: isUser
                              ? null
                              : Border.all(color: AppColors.border, width: 0.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isUser)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: AppColors.teal,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(Icons.smart_toy_outlined, size: 10, color: AppColors.primaryDark),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'AI Assistant',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Text(
                              msg['text']!,
                              style: TextStyle(
                                fontSize: 13,
                                color: isUser ? Colors.white : AppColors.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_isLoading)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'AI sedang mengetik...',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    top: BorderSide(
                      color: AppColors.border,
                      width: 0.5,
                    ),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: TextField(
                            controller: _controller,
                            enabled: !_isLoading,
                            decoration: const InputDecoration(
                              hintText: 'Tanyakan sesuatu...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            style: const TextStyle(fontSize: 13),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _isLoading ? null : _sendMessage,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: _isLoading ? AppColors.textMuted : AppColors.primary,
                            borderRadius: BorderRadius.circular(21),
                          ),
                          child: const Icon(Icons.send, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
