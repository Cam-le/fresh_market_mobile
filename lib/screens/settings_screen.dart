import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'change_password_screen.dart';
import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _pushNotifs = true;
  bool _orderNotifs = true;
  bool _promoNotifs = true;
  bool _emailNotifs = false;
  bool _faceId = false;
  String _language = 'Tiếng Việt';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = p.getBool('dark_mode') ?? false;
      _pushNotifs = p.getBool('push_notifs') ?? true;
      _orderNotifs = p.getBool('order_notifs') ?? true;
      _promoNotifs = p.getBool('promo_notifs') ?? true;
      _emailNotifs = p.getBool('email_notifs') ?? false;
    });
  }

  Future<void> _save(String key, bool val) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(key, val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        children: [
          // Appearance
          const _SectionHeader('GIAO DIỆN'),
          _ToggleTile(
            icon: Icons.dark_mode_outlined,
            iconColor: const Color(0xFF5C6BC0),
            title: 'Chế độ tối',
            subtitle: 'Giảm mỏi mắt khi dùng ban đêm',
            value: _darkMode,
            onChanged: (v) {
              setState(() => _darkMode = v);
              _save('dark_mode', v);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Chế độ tối sẽ có trong bản cập nhật tiếp theo'),
                behavior: SnackBarBehavior.floating,
              ));
            },
          ),
          _NavigateTile(
            icon: Icons.language,
            iconColor: const Color(0xFF00897B),
            title: 'Ngôn ngữ',
            trailing: _language,
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20))),
                builder: (_) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16),
                    const Text('Chọn ngôn ngữ',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    ...['Tiếng Việt', 'English', '中文'].map((l) => ListTile(
                          title: Text(l),
                          trailing: _language == l
                              ? const Icon(Icons.check,
                                  color: AppTheme.primaryGreen)
                              : null,
                          onTap: () {
                            setState(() => _language = l);
                            Navigator.pop(context);
                          },
                        )),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
          _NavigateTile(
            icon: Icons.text_fields,
            iconColor: const Color(0xFF6D4C41),
            title: 'Cỡ chữ',
            trailing: 'Trung bình',
            onTap: () {},
          ),
          const Divider(height: 8),

          // Notifications
          const _SectionHeader('THÔNG BÁO'),
          _ToggleTile(
            icon: Icons.notifications_outlined,
            iconColor: AppTheme.accentOrange,
            title: 'Thông báo đẩy',
            subtitle: 'Nhận thông báo về đơn hàng và ưu đãi',
            value: _pushNotifs,
            onChanged: (v) {
              setState(() => _pushNotifs = v);
              _save('push_notifs', v);
            },
          ),
          _ToggleTile(
            icon: Icons.shopping_bag_outlined,
            iconColor: AppTheme.primaryGreen,
            title: 'Đơn hàng',
            subtitle: 'Cập nhật trạng thái đơn hàng',
            value: _orderNotifs,
            onChanged: _pushNotifs
                ? (v) {
                    setState(() => _orderNotifs = v);
                    _save('order_notifs', v);
                  }
                : null,
          ),
          _ToggleTile(
            icon: Icons.local_offer_outlined,
            iconColor: const Color(0xFF8E24AA),
            title: 'Khuyến mãi',
            subtitle: 'Flash sale, mã giảm giá mới',
            value: _promoNotifs,
            onChanged: _pushNotifs
                ? (v) {
                    setState(() => _promoNotifs = v);
                    _save('promo_notifs', v);
                  }
                : null,
          ),
          _ToggleTile(
            icon: Icons.email_outlined,
            iconColor: const Color(0xFF1E88E5),
            title: 'Email',
            subtitle: 'Nhận bản tin và ưu đãi qua email',
            value: _emailNotifs,
            onChanged: (v) {
              setState(() => _emailNotifs = v);
              _save('email_notifs', v);
            },
          ),
          const Divider(height: 8),

          // Security
          const _SectionHeader('BẢO MẬT'),
          _ToggleTile(
            icon: Icons.fingerprint,
            iconColor: const Color(0xFF00897B),
            title: 'Face ID / Touch ID',
            subtitle: 'Đăng nhập bằng sinh trắc học',
            value: _faceId,
            onChanged: (v) => setState(() => _faceId = v),
          ),
          _NavigateTile(
            icon: Icons.lock_outline,
            iconColor: const Color(0xFFE53935),
            title: 'Đổi mật khẩu',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ChangePasswordScreen())),
          ),
          _NavigateTile(
            icon: Icons.devices_outlined,
            iconColor: const Color(0xFF546E7A),
            title: 'Thiết bị đã đăng nhập',
            trailing: '2 thiết bị',
            onTap: () {},
          ),
          const Divider(height: 8),

          // Privacy
          const _SectionHeader('QUYỀN RIÊNG TƯ'),
          _NavigateTile(
            icon: Icons.location_on_outlined,
            iconColor: AppTheme.accentOrange,
            title: 'Quyền truy cập vị trí',
            trailing: 'Khi dùng app',
            onTap: () {},
          ),
          _NavigateTile(
            icon: Icons.delete_outline,
            iconColor: AppTheme.discountRed,
            title: 'Xoá dữ liệu cá nhân',
            onTap: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Xoá dữ liệu?'),
                content: const Text(
                    'Toàn bộ dữ liệu cá nhân sẽ bị xoá vĩnh viễn. Bạn có chắc không?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Huỷ')),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Xoá',
                        style: TextStyle(color: AppTheme.discountRed)),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 8),

          // App info
          const _SectionHeader('ỨNG DỤNG'),
          _NavigateTile(
            icon: Icons.info_outline,
            iconColor: const Color(0xFF1565C0),
            title: 'Về ứng dụng',
            trailing: 'v1.0.0',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AboutScreen())),
          ),
          _NavigateTile(
            icon: Icons.policy_outlined,
            iconColor: const Color(0xFF37474F),
            title: 'Chính sách bảo mật',
            onTap: () {},
          ),
          _NavigateTile(
            icon: Icons.article_outlined,
            iconColor: const Color(0xFF37474F),
            title: 'Điều khoản sử dụng',
            onTap: () {},
          ),
          _NavigateTile(
            icon: Icons.star_rate_outlined,
            iconColor: AppTheme.accentOrange,
            title: 'Đánh giá ứng dụng',
            onTap: () {},
          ),
          const SizedBox(height: 40),
          Center(
            child: Text('Phiên bản 1.0.0 (Build 1)',
                style: TextStyle(fontSize: 12, color: Colors.grey[400])),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(title,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.textLight,
                letterSpacing: 0.8)),
      );
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        child: ListTile(
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon,
                size: 20, color: onChanged == null ? Colors.grey : iconColor),
          ),
          title: Text(title,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: onChanged == null ? Colors.grey : AppTheme.textDark)),
          subtitle: subtitle != null
              ? Text(subtitle!,
                  style:
                      const TextStyle(fontSize: 12, color: AppTheme.textLight))
              : null,
          trailing: Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryGreen,
          ),
        ),
      );
}

class _NavigateTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? trailing;
  final VoidCallback onTap;

  const _NavigateTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        child: ListTile(
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          title: Text(title,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailing != null)
                Text(trailing!,
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textLight)),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right,
                  size: 18, color: AppTheme.textLight),
            ],
          ),
          onTap: onTap,
        ),
      );
}
