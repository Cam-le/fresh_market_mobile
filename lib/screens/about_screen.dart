// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppTheme.primaryGreen,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.darkGreen, AppTheme.lightGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20)
                        ],
                      ),
                      child: const Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.fork_right,
                              color: Color(0xFFF5A623), size: 48),
                          Positioned(
                            top: 12,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.eco,
                                    color: AppTheme.primaryGreen, size: 22),
                                Icon(Icons.eco,
                                    color: Color(0xFF8BC34A), size: 18),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Ăn Sạch Sống Khỏe',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800)),
                    const Text('Phiên bản 1.0.0',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ),
            title: const Text('Về ứng dụng'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoCard(
                    title: 'Sứ mệnh của chúng tôi',
                    content:
                        'Mang thực phẩm sạch, tươi ngon từ nông trại đến bàn ăn của mỗi gia đình Việt Nam với giá cả hợp lý và dịch vụ giao hàng nhanh chóng.',
                    icon: Icons.eco_outlined,
                    color: AppTheme.primaryGreen,
                  ),
                  const SizedBox(height: 16),
                  _InfoCard(
                    title: 'Cam kết của chúng tôi',
                    content:
                        '100% thực phẩm đạt chuẩn VietGAP, không thuốc trừ sâu, không chất bảo quản. Kiểm định chất lượng mỗi ngày trước khi giao đến tay bạn.',
                    icon: Icons.verified_outlined,
                    color: const Color(0xFF1E88E5),
                  ),
                  const SizedBox(height: 24),
                  const Text('Thông tin liên hệ',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _ContactRow(
                      icon: Icons.email_outlined,
                      label: 'Email hỗ trợ',
                      value: 'support@ansachsongkhoe.vn'),
                  _ContactRow(
                      icon: Icons.phone_outlined,
                      label: 'Hotline',
                      value: '1800 1234 (Miễn phí)'),
                  _ContactRow(
                      icon: Icons.language,
                      label: 'Website',
                      value: 'www.ansachsongkhoe.vn'),
                  _ContactRow(
                      icon: Icons.location_on_outlined,
                      label: 'Trụ sở',
                      value: '123 Nguyễn Huệ, Q.1, TP.HCM'),
                  const SizedBox(height: 24),
                  const Text('Theo dõi chúng tôi',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      _SocialBtn(
                          label: 'Facebook',
                          color: Color(0xFF1877F2),
                          icon: Icons.facebook),
                      SizedBox(width: 10),
                      _SocialBtn(
                          label: 'Instagram',
                          color: Color(0xFFE1306C),
                          icon: Icons.camera_alt_outlined),
                      SizedBox(width: 10),
                      _SocialBtn(
                          label: 'YouTube',
                          color: Color(0xFFFF0000),
                          icon: Icons.play_circle_outline),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),
                  Center(
                    child: Column(
                      children: [
                        Text('Build: 1 • SDK Flutter 3.x • Dart 3.x',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[400])),
                        const SizedBox(height: 4),
                        Text('© 2026 Ăn Sạch Sống Khỏe. All rights reserved.',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[400])),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.title,
    required this.content,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: color)),
                  const SizedBox(height: 6),
                  Text(content,
                      style: const TextStyle(
                          fontSize: 13, color: AppTheme.textGray, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.primaryGreen),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textLight)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textDark)),
              ],
            ),
          ],
        ),
      );
}

class _SocialBtn extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _SocialBtn(
      {required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: 4),
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      );
}
