import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1C1C1C),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top section ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo + tagline
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.eco, color: Colors.white, size: 22),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ăn Sạch Sống Khỏe',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Thực phẩm sạch, tươi ngon mỗi ngày',
                          style: TextStyle(
                            color: Color(0xFF9E9E9E),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Description
                const Text(
                  'Cung cấp thực phẩm tươi sống, sạch và an toàn cho sức khỏe gia đình bạn.',
                  style: TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 14),
                // Social icons
                Row(
                  children: [
                    _SocialBtn(
                      label: 'f',
                      color: const Color(0xFF1877F2),
                      onTap: () {},
                    ),
                    const SizedBox(width: 10),
                    _SocialBtn(
                      icon: Icons.camera_alt_outlined,
                      color: const Color(0xFFE1306C),
                      onTap: () {},
                    ),
                    const SizedBox(width: 10),
                    _SocialBtn(
                      icon: Icons.play_circle_fill,
                      color: const Color(0xFFFF0000),
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(color: Color(0xFF2E2E2E), height: 1),

          // ── Link columns ─────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _FooterCol(
                    title: 'Về Chúng Tôi',
                    items: ['Giới thiệu', 'Sản phẩm', 'Tin tức', 'Liên hệ'],
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _FooterCol(
                    title: 'Hỗ Trợ',
                    items: [
                      'Chính sách bảo mật',
                      'Điều khoản sử dụng',
                      'Chính sách đổi trả',
                      'Hướng dẫn mua hàng',
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Liên Hệ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 12),
                      _ContactRow(
                          icon: Icons.location_on_outlined,
                          text: '123 Đường ABC, Quận 1, TP.HCM'),
                      SizedBox(height: 8),
                      _ContactRow(
                          icon: Icons.phone_outlined, text: '1900 xxxx'),
                      SizedBox(height: 8),
                      _ContactRow(
                          icon: Icons.email_outlined,
                          text: 'info@freshmarket.vn'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Color(0xFF2E2E2E), height: 1),

          // ── Copyright ─────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Center(
              child: Text(
                '© 2026 Ăn Sạch Sống Khỏe. All rights reserved.',
                style: TextStyle(color: Color(0xFF616161), fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final Color color;
  final VoidCallback onTap;

  const _SocialBtn({
    this.label,
    this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        alignment: Alignment.center,
        child: label != null
            ? Text(label!,
                style: TextStyle(
                    color: color, fontSize: 16, fontWeight: FontWeight.w900))
            : Icon(icon!, color: color, size: 18),
      ),
    );
  }
}

class _FooterCol extends StatelessWidget {
  final String title;
  final List<String> items;

  const _FooterCol({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              item,
              style: const TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: AppTheme.primaryGreen),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
