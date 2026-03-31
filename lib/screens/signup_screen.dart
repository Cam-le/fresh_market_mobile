import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (phone.isEmpty || password.isEmpty || confirm.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập đầy đủ thông tin');
      return;
    }
    if (phone.length < 9) {
      setState(() => _errorMessage = 'Số điện thoại không hợp lệ');
      return;
    }
    if (password != confirm) {
      setState(() => _errorMessage = 'Mật khẩu xác nhận không khớp');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'Mật khẩu phải có ít nhất 6 ký tự');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AuthService.register(phone, password);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (!result.isSuccess) {
      setState(() => _errorMessage = result.error);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đăng kí thành công!'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.fork_right, color: Colors.white, size: 36),
                          Positioned(
                            top: 8,
                            child: Icon(Icons.eco,
                                color: Colors.white70, size: 18),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Ăn Sạch Sống Khỏe',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              const Text(
                'Đăng Kí',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    'Đã có tài khoản? ',
                    style: TextStyle(fontSize: 14, color: AppTheme.textGray),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Đăng nhập ngay',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Error message
              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.discountRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppTheme.discountRed.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppTheme.discountRed, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                              color: AppTheme.discountRed, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Phone
              const Text(
                'Số điện thoại',
                style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textGray,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                onChanged: (_) {
                  if (_errorMessage != null) {
                    setState(() => _errorMessage = null);
                  }
                },
                decoration: const InputDecoration(
                  hintText: '09xxxxxxxx',
                  prefixIcon: Icon(Icons.phone_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              const Text(
                'Mật Khẩu',
                style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textGray,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                onChanged: (_) {
                  if (_errorMessage != null) {
                    setState(() => _errorMessage = null);
                  }
                },
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppTheme.textLight,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Confirm password
              const Text(
                'Xác nhận mật khẩu',
                style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textGray,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                onChanged: (_) {
                  if (_errorMessage != null) {
                    setState(() => _errorMessage = null);
                  }
                },
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppTheme.textLight,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Signup button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignup,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Đăng Kí',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
