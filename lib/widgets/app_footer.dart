import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A1A),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo row
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5A623),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Icon(Icons.fork_right, color: Colors.white, size: 18),
                    const Positioned(
                      top: 4,
                      child: Icon(Icons.eco,
                          color: AppTheme.primaryGreen, size: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Social icons
          Row(
            children: [
              _SocialIcon(icon: Icons.close, onTap: () {}),
              const SizedBox(width: 12),
              _SocialIcon(icon: Icons.camera_alt_outlined, onTap: () {}),
              const SizedBox(width: 12),
              _SocialIcon(icon: Icons.play_circle_outline, onTap: () {}),
              const SizedBox(width: 12),
              _SocialIcon(icon: Icons.business, onTap: () {}),
            ],
          ),
          const SizedBox(height: 24),
          // Footer columns
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _FooterColumn(
                  title: 'Use cases',
                  items: [
                    'Rau củ sạch',
                    'Trái cây tươi',
                    'Hải sản tươi sống',
                    'Thịt sạch',
                    'Ngũ cốc',
                    'Giao hàng nhanh',
                    'Combo gia đình',
                  ],
                ),
              ),
              Expanded(
                child: _FooterColumn(
                  title: 'Khám phá',
                  items: [
                    'Ưu đãi hôm nay',
                    'Sản phẩm mới',
                    'Tính năng giao hàng',
                    'Hệ thống cửa hàng',
                    'Đặt hàng nhóm',
                    'Quy trình đặt hàng',
                    'Điểm tích lũy',
                  ],
                ),
              ),
              Expanded(
                child: _FooterColumn(
                  title: 'Tài nguyên',
                  items: [
                    'Blog sức khỏe',
                    'Công thức nấu ăn',
                    'Bảng màu dinh dưỡng',
                    'Liên hệ',
                    'Hỗ trợ khách hàng',
                    'Nhà cung cấp',
                    'Thư viện ảnh',
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFF333333)),
          const SizedBox(height: 12),
          const Text(
            '© 2026 Ăn Sạch Sống Khỏe. All rights reserved.',
            style: TextStyle(
              color: Color(0xFF757575),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SocialIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF333333),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<String> items;

  const _FooterColumn({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () {},
              child: Text(
                item,
                style: const TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
