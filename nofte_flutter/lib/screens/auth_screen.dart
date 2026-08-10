import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import 'main_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _authStep = 0; // 0=form, 1=otp, 2=reset
  bool _isLoading = false;
  String _errorMessage = '';

  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showError(_errorMessage);
        _errorMessage = '';
      });
    }

    if (_authStep == 0) {
      return _isLogin ? _buildLoginForm() : _buildRegisterForm();
    } else if (_authStep == 1) {
      return _buildOTPForm();
    } else {
      return _buildResetPasswordForm();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.tealDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Email dan password harus diisi');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Terjadi kesalahan. Coba lagi.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRegister() async {
    if (_nameController.text.isEmpty) {
      setState(() => _errorMessage = 'Nama harus diisi');
      return;
    }
    if (_emailController.text.isEmpty) {
      setState(() => _errorMessage = 'Email harus diisi');
      return;
    }
    if (_passwordController.text.length < 8) {
      setState(() => _errorMessage = 'Password minimal 8 karakter');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Password tidak cocok');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        _showSuccess('Registrasi berhasil! Silakan login.');
        setState(() {
          _isLogin = true;
          _passwordController.clear();
          _confirmPasswordController.clear();
        });
      }
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Terjadi kesalahan. Coba lagi.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        _buildHeader('Selamat Datang!', 'Masuk untuk melanjutkan'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInput('Email', 'nama@email.com', controller: _emailController, isEmail: true),
                const SizedBox(height: 12),
                _buildInput('Password', 'Masukkan password', controller: _passwordController, isPassword: true),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => setState(() => _authStep = 1),
                    child: const Text(
                      'Lupa Password?',
                      style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildPrimaryButton('Masuk', onPressed: _handleLogin),
                const SizedBox(height: 12),
                _buildBiometricButton(),
                const SizedBox(height: 16),
                _buildDivider('atau'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildSocialButton('Google', Colors.red)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildSocialButton('Facebook', Colors.blue.shade600)),
                  ],
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => setState(() {
                    _isLogin = false;
                    _emailController.clear();
                    _passwordController.clear();
                  }),
                  child: RichText(
                    text: const TextSpan(
                      text: 'Belum punya akun? ',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      children: [
                        TextSpan(
                          text: 'Daftar',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      children: [
        _buildHeader('Buat Akun Baru', 'Bergabung & mulai kurangi food waste'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInput('Nama Lengkap', 'Masukkan nama lengkap', controller: _nameController),
                const SizedBox(height: 12),
                _buildInput('Email', 'nama@email.com', controller: _emailController, isEmail: true),
                const SizedBox(height: 12),
                _buildInput('Password', 'Min. 8 karakter', controller: _passwordController, isPassword: true),
                const SizedBox(height: 12),
                _buildInput('Konfirmasi Password', 'Ulangi password', controller: _confirmPasswordController, isPassword: true, isConfirmed: true),
                const SizedBox(height: 16),
                _buildCheckbox('Saya menyetujui Syarat & Ketentuan serta Kebijakan Privasi'),
                const SizedBox(height: 16),
                _buildPrimaryButton('Daftar Sekarang', onPressed: _handleRegister),
                const SizedBox(height: 16),
                _buildDivider('atau'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildSocialButton('Google', Colors.red)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildSocialButton('Facebook', Colors.blue.shade600)),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _isLogin = true;
                      _nameController.clear();
                      _emailController.clear();
                      _passwordController.clear();
                      _confirmPasswordController.clear();
                    }),
                    child: RichText(
                      text: const TextSpan(
                        text: 'Sudah punya akun? ',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        children: [
                          TextSpan(
                            text: 'Masuk',
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOTPForm() {
    return Column(
      children: [
        _buildHeader('Kode OTP', 'Masukkan 6 digit kode yang dikirim ke email', icon: Icons.message_outlined),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Langkah 2 dari 3',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildOTPBox('7', true),
                    _buildOTPBox('3', true),
                    _buildOTPBox('8', true),
                    _buildOTPBox('', false),
                    _buildOTPBox('', false),
                    _buildOTPBox('', false),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Kode berlaku 02:34',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: const TextSpan(
                    text: 'Belum terima? ',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    children: [
                      TextSpan(
                        text: 'Kirim ulang',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildPrimaryButton('Verifikasi Kode', onPressed: () => setState(() => _authStep = 2)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => setState(() => _authStep = 0),
                  child: const Text(
                    'Ingat password? Kembali Login',
                    style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResetPasswordForm() {
    return Column(
      children: [
        _buildHeader('Buat Password Baru', 'OTP terverifikasi ✓', icon: Icons.lock_outline),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Langkah 3 dari 3',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                _buildInput('Password Baru', 'Min. 8 karakter', controller: _passwordController, isPassword: true),
                const SizedBox(height: 12),
                _buildInput('Konfirmasi Password Baru', 'Ulangi password baru', controller: _confirmPasswordController, isPassword: true, isConfirmed: true),
                const SizedBox(height: 16),
                _buildPasswordStrength(),
                const SizedBox(height: 16),
                _buildPrimaryButton('Simpan Password Baru', onPressed: () {
                  _showSuccess('Password berhasil diubah!');
                  setState(() => _authStep = 0);
                }),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: AppColors.freshBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline, size: 14, color: AppColors.freshText),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Password baru akan langsung aktif dan kamu akan diarahkan ke halaman login.',
                          style: TextStyle(fontSize: 10, color: AppColors.freshText),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String title, String subtitle, {IconData? icon}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon ?? Icons.lock_outline,
              color: AppColors.teal,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: Colors.white.withAlpha(153)),
          ),
          const SizedBox(height: 20),
          Container(
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, String placeholder, {
    TextEditingController? controller,
    bool isEmail = false,
    bool isPassword = false,
    bool isConfirmed = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: isPassword && (isConfirmed ? _obscureConfirmPassword : _obscurePassword),
          keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      (isConfirmed ? _obscureConfirmPassword : _obscurePassword)
                          ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textMuted,
                      size: 18,
                    ),
                    onPressed: () {
                      setState(() {
                        if (isConfirmed) {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        } else {
                          _obscurePassword = !_obscurePassword;
                        }
                      });
                    },
                  )
                : (isConfirmed
                    ? const Icon(Icons.check_circle, color: AppColors.tealDark, size: 16)
                    : (isEmail
                        ? const Icon(Icons.email_outlined, color: AppColors.primary, size: 16)
                        : null)),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(String text, {VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildBiometricButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.fingerprint, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Text(
            'Face ID / Sidik Jari',
            style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(String text) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(text, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ),
        Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }

  Widget _buildSocialButton(String text, Color brandColor) {
    IconData icon = text == 'Google' ? Icons.g_mobiledata : Icons.facebook;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: brandColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(Icons.check, size: 12, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: 'Saya menyetujui ',
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              children: const [
                TextSpan(
                  text: 'Syarat & Ketentuan',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500),
                ),
                TextSpan(text: ' serta '),
                TextSpan(
                  text: 'Kebijakan Privasi',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOTPBox(String digit, bool isFilled) {
    return Container(
      width: 40,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: isFilled ? AppColors.freshBg : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isFilled ? AppColors.primary : (digit.isEmpty ? AppColors.border : AppColors.primary),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          digit,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isFilled ? AppColors.primary : Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordStrength() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Kekuatan password', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            Text('Kuat', style: TextStyle(fontSize: 10, color: AppColors.tealDark, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(child: Container(height: 3, decoration: BoxDecoration(color: AppColors.tealDark, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(width: 3),
            Expanded(child: Container(height: 3, decoration: BoxDecoration(color: AppColors.tealDark, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(width: 3),
            Expanded(child: Container(height: 3, decoration: BoxDecoration(color: AppColors.tealDark, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(width: 3),
            Expanded(child: Container(height: 3, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
          ],
        ),
      ],
    );
  }
}
