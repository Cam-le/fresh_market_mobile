import 'package:flutter/material.dart';
import '../models/app_state.dart';
// import '../models/user.dart';
import '../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  final AppState appState;
  const EditProfileScreen({super.key, required this.appState});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _cityCtrl;
  String? _selectedGender = 'Nam';
  DateTime? _dob;
  bool _isLoading = false;

  static const List<String> _cities = [
    'TP. Hồ Chí Minh',
    'Hà Nội',
    'Đà Nẵng',
    'Cần Thơ',
    'Hải Phòng',
    'Biên Hoà',
    'Huế',
    'Nha Trang',
  ];

  @override
  void initState() {
    super.initState();
    final u = widget.appState.user;
    _nameCtrl = TextEditingController(text: u.name);
    _emailCtrl = TextEditingController(text: u.email);
    _phoneCtrl = TextEditingController(text: u.phone);
    _cityCtrl = TextEditingController(text: u.city);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(1995, 6, 15),
      firstDate: DateTime(1940),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 16)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primaryGreen),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _showError('Vui lòng nhập họ và tên');
      return;
    }
    if (!_emailCtrl.text.contains('@')) {
      _showError('Email không hợp lệ');
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));

    widget.appState.updateUser(
      widget.appState.user.copyWith(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
      ),
    );

    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Cập nhật thông tin thành công!'),
          ]),
          backgroundColor: AppTheme.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      Navigator.pop(context);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppTheme.discountRed,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: const Text('Lưu',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Avatar hero
            Container(
              color: AppTheme.primaryGreen,
              padding: const EdgeInsets.only(bottom: 28),
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 52,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person,
                                size: 56,
                                color: AppTheme.primaryGreen
                                    .withValues(alpha: 0.7)),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () =>
                                ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Tính năng đổi ảnh sẽ có trong bản tiếp theo'),
                                  behavior: SnackBarBehavior.floating),
                            ),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: const BoxDecoration(
                                color: AppTheme.accentOrange,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black26, blurRadius: 4)
                                ],
                              ),
                              child: const Icon(Icons.camera_alt,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.appState.user.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
                    ),
                    Text(
                      widget.appState.user.email,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Personal info ──────────────────────────────────
                  const _SectionTitle('Thông tin cá nhân'),
                  const SizedBox(height: 12),

                  _Field(
                    label: 'Họ và tên',
                    controller: _nameCtrl,
                    icon: Icons.person_outline,
                    hint: 'Nguyễn Văn A',
                  ),
                  const SizedBox(height: 14),
                  _Field(
                    label: 'Email',
                    controller: _emailCtrl,
                    icon: Icons.email_outlined,
                    hint: 'example@gmail.com',
                    type: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  _Field(
                    label: 'Số điện thoại',
                    controller: _phoneCtrl,
                    icon: Icons.phone_outlined,
                    hint: '0901 234 567',
                    type: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),

                  // Gender
                  const Text('Giới tính',
                      style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textGray,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Row(
                    children: ['Nam', 'Nữ', 'Khác'].map((g) {
                      final selected = _selectedGender == g;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedGender = g),
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color:
                                selected ? AppTheme.primaryGreen : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected
                                  ? AppTheme.primaryGreen
                                  : const Color(0xFFE0E0E0),
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Text(g,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color:
                                    selected ? Colors.white : AppTheme.textGray,
                              )),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // DOB
                  const Text('Ngày sinh',
                      style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textGray,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDob,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.cake_outlined,
                              color: AppTheme.textLight, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            _dob == null
                                ? 'Chọn ngày sinh'
                                : '${_dob!.day.toString().padLeft(2, '0')}/${_dob!.month.toString().padLeft(2, '0')}/${_dob!.year}',
                            style: TextStyle(
                              fontSize: 14,
                              color: _dob == null
                                  ? AppTheme.textLight
                                  : AppTheme.textDark,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_drop_down,
                              color: AppTheme.textLight),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Location ────────────────────────────────────────
                  const _SectionTitle('Khu vực'),
                  const SizedBox(height: 12),

                  // City dropdown
                  const Text('Thành phố / Tỉnh',
                      style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textGray,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _cities.contains(_cityCtrl.text)
                            ? _cityCtrl.text
                            : _cities.first,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down,
                            color: AppTheme.textLight),
                        onChanged: (v) => setState(() => _cityCtrl.text = v!),
                        items: _cities
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c,
                                      style: const TextStyle(fontSize: 14)),
                                ))
                            .toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Lưu thay đổi',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(text,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        ],
      );
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final TextInputType type;

  const _Field({
    required this.label,
    required this.controller,
    required this.icon,
    required this.hint,
    this.type = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textGray,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: type,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, size: 20, color: AppTheme.textLight),
              floatingLabelStyle: const TextStyle(color: AppTheme.primaryGreen),
            ),
          ),
        ],
      );
}
