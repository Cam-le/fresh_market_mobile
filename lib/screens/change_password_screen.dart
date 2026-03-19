import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _hideCurrent = true;
  bool _hideNew = true;
  bool _hideConfirm = true;
  bool _isLoading = false;

  int get _strength {
    final p = _newCtrl.text;
    if (p.isEmpty) return 0;
    int score = 0;
    if (p.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(p)) score++;
    if (RegExp(r'[0-9]').hasMatch(p)) score++;
    if (RegExp(r'[!@#\$&*~]').hasMatch(p)) score++;
    return score;
  }

  Color get _strengthColor {
    switch (_strength) {
      case 1: return AppTheme.discountRed;
      case 2: return AppTheme.accentOrange;
      case 3: return const Color(0xFFFFC107);
      case 4: return AppTheme.primaryGreen;
      default: return Colors.grey;
    }
  }

  String get _strengthLabel {
    switch (_strength) {
      case 1: return 'Yếu';
      case 2: return 'Trung bình';
      case 3: return 'Khá';
      case 4: return 'Mạnh';
      default: return '';
    }
  }

  Future<void> _submit() async {
    if (_newCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Mật khẩu xác nhận không khớp'),
        backgroundColor: AppTheme.discountRed,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    if (_strength < 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Mật khẩu quá yếu, vui lòng chọn mật khẩu mạnh hơn'),
        backgroundColor: AppTheme.accentOrange,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('✅ Đổi mật khẩu thành công!'),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đổi mật khẩu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF1E88E5), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Mật khẩu phải có ít nhất 8 ký tự, bao gồm chữ hoa, số và ký tự đặc biệt.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF1565C0), height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text('Mật khẩu hiện tại',
                style: TextStyle(fontSize: 13, color: AppTheme.textGray, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            _PasswordField(
              controller: _currentCtrl,
              hint: 'Nhập mật khẩu hiện tại',
              obscure: _hideCurrent,
              onToggle: () => setState(() => _hideCurrent = !_hideCurrent),
            ),
            const SizedBox(height: 20),
            const Text('Mật khẩu mới',
                style: TextStyle(fontSize: 13, color: AppTheme.textGray, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            _PasswordField(
              controller: _newCtrl,
              hint: 'Nhập mật khẩu mới',
              obscure: _hideNew,
              onToggle: () => setState(() => _hideNew = !_hideNew),
              onChanged: (_) => setState(() {}),
            ),
            // Strength meter
            if (_newCtrl.text.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: _strength / 4,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFE0E0E0),
                        valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(_strengthLabel,
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600, color: _strengthColor)),
                ],
              ),
              const SizedBox(height: 8),
              // Checklist
              _PasswordCheck('Ít nhất 8 ký tự', _newCtrl.text.length >= 8),
              _PasswordCheck('Có chữ hoa (A-Z)', RegExp(r'[A-Z]').hasMatch(_newCtrl.text)),
              _PasswordCheck('Có số (0-9)', RegExp(r'[0-9]').hasMatch(_newCtrl.text)),
              _PasswordCheck('Có ký tự đặc biệt (!@#\$)', RegExp(r'[!@#\$&*~]').hasMatch(_newCtrl.text)),
            ],
            const SizedBox(height: 20),
            const Text('Xác nhận mật khẩu mới',
                style: TextStyle(fontSize: 13, color: AppTheme.textGray, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            _PasswordField(
              controller: _confirmCtrl,
              hint: 'Nhập lại mật khẩu mới',
              obscure: _hideConfirm,
              onToggle: () => setState(() => _hideConfirm = !_hideConfirm),
              onChanged: (_) => setState(() {}),
            ),
            if (_confirmCtrl.text.isNotEmpty &&
                _newCtrl.text != _confirmCtrl.text)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text('Mật khẩu không khớp',
                    style: TextStyle(fontSize: 12, color: AppTheme.discountRed)),
              ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Đổi mật khẩu',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final VoidCallback onToggle;
  final ValueChanged<String>? onChanged;

  const _PasswordField({
    required this.controller,
    required this.hint,
    required this.obscure,
    required this.onToggle,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        obscureText: obscure,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textLight, size: 20),
          suffixIcon: IconButton(
            onPressed: onToggle,
            icon: Icon(
              obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: AppTheme.textLight,
              size: 20,
            ),
          ),
        ),
      );
}

class _PasswordCheck extends StatelessWidget {
  final String label;
  final bool passed;

  const _PasswordCheck(this.label, this.passed);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Icon(
              passed ? Icons.check_circle : Icons.circle_outlined,
              size: 14,
              color: passed ? AppTheme.primaryGreen : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: passed ? AppTheme.primaryGreen : AppTheme.textLight)),
          ],
        ),
      );
}
