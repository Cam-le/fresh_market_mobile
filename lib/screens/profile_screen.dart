// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'notifications_screen.dart';
import 'wishlist_screen.dart';
import 'address_book_screen.dart';
import 'promo_code_screen.dart';
import 'orders_screen.dart';
import 'settings_screen.dart';
import 'edit_profile_screen.dart';
import 'help_screen.dart';
import 'change_password_screen.dart';
import 'loyalty_screen.dart';
import 'payment_methods_screen.dart';
import 'cart_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends StatelessWidget {
  final AppState appState;
  const ProfileScreen({super.key, required this.appState});

  void _go(BuildContext context, Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final orderCount = appState.orders.length;
        final wishCount = appState.wishlist.count;
        final cartCount = appState.cart.itemCount;
        final user = appState.user;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Tài khoản'),
            actions: [
              Stack(
                children: [
                  IconButton(
                    onPressed: () => _go(context, const NotificationsScreen()),
                    icon: const Icon(Icons.notifications_outlined),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: AppTheme.discountRed, shape: BoxShape.circle),
                    ),
                  ),
                ],
              ),
              IconButton(
                  onPressed: () => _go(context, const SettingsScreen()),
                  icon: const Icon(Icons.settings_outlined)),
            ],
          ),
          body: ListView(
            children: [
              // Profile header
              Container(
                color: AppTheme.primaryGreen,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar
                    GestureDetector(
                      onTap: () => _go(context, EditProfileScreen(appState: appState)),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 34,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person,
                                size: 38, color: AppTheme.primaryGreen),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                color: AppTheme.accentOrange,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit,
                                  size: 13, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Name / email / city
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            user.email,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          if (user.city.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              '📍 ${user.city}',
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ],
                      ),
                    ),
                    // VIP badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.accentOrange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.stars, size: 11, color: Colors.white),
                          SizedBox(width: 3),
                          Text('VIP',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Stats row
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: [
                    _StatItem(
                        value: '$orderCount',
                        label: 'Đơn hàng',
                        icon: Icons.shopping_bag_outlined,
                        onTap: () =>
                            _go(context, OrdersScreen(appState: appState))),
                    _StatDivider(),
                    _StatItem(
                        value: '$cartCount',
                        label: 'Giỏ hàng',
                        icon: Icons.shopping_cart_outlined,
                        onTap: () => _go(context, CartScreen(appState: appState))),
                    _StatDivider(),
                    _StatItem(
                        value: '$wishCount',
                        label: 'Yêu thích',
                        icon: Icons.favorite_border,
                        onTap: () =>
                            _go(context, WishlistScreen(appState: appState))),
                    _StatDivider(),
                    _StatItem(
                        value: '${appState.loyaltyPoints}',
                        label: 'Điểm',
                        icon: Icons.stars_outlined,
                        onTap: () => _go(context, LoyaltyScreen(appState: appState))),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Loyalty bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.workspace_premium,
                            size: 16, color: AppTheme.accentOrange),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text('Thành viên VIP',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700)),
                        ),
                        Text('${appState.loyaltyPoints} / 500 điểm',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[500])),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (appState.loyaltyPoints / 500).clamp(0.0, 1.0),
                        minHeight: 7,
                        backgroundColor: Color(0xFFE0E0E0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.accentOrange),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text('Mua thêm 250.000₫ để lên hạng VIP+',
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey[500])),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              _MenuGroup(
                title: 'ĐƠN HÀNG',
                items: [
                  _MenuItem(
                      icon: Icons.shopping_bag_outlined,
                      label: 'Đơn hàng của tôi',
                      badge: orderCount > 0 ? '$orderCount' : null,
                      onTap: () =>
                          _go(context, OrdersScreen(appState: appState))),
                  _MenuItem(
                      icon: Icons.local_shipping_outlined,
                      label: 'Theo dõi đơn hàng',
                      onTap: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Theo dõi đơn hàng'),
                        content: const Text(
                          'Chức năng theo dõi thời gian thực sẽ khả dụng sau khi tích hợp đơn vị vận chuyển. '
                          'Hiện tại, bạn có thể xem trạng thái đơn hàng trong mục Đơn hàng của tôi.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Đóng'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _go(context, OrdersScreen(appState: appState));
                            },
                            child: const Text('Xem đơn hàng'),
                          ),
                        ],
                      ),
                    )),
                  _MenuItem(
                      icon: Icons.assignment_return_outlined,
                      label: 'Đổi trả hàng',
                      onTap: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Chính sách đổi trả'),
                        content: const Text(
                          '• Đổi trả trong vòng 24 giờ kể từ khi nhận hàng\n'
                          '• Sản phẩm còn nguyên vẹn, chưa qua sử dụng\n'
                          '• Liên hệ hotline 1800 1234 hoặc chat với chúng tôi\n\n'
                          'Chức năng tạo yêu cầu đổi trả trực tuyến sẽ sớm ra mắt.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Đóng'),
                          ),
                        ],
                      ),
                    )),
                  _MenuItem(
                      icon: Icons.rate_review_outlined,
                      label: 'Đánh giá của tôi',
                      onTap: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Đánh giá của tôi'),
                        content: const Text(
                          'Bạn chưa có đánh giá nào. Hãy mua sắm và chia sẻ '
                          'cảm nhận về sản phẩm để giúp cộng đồng nhé!',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Đóng'),
                          ),
                        ],
                      ),
                    )),
                ],
              ),

              const SizedBox(height: 8),

              _MenuGroup(
                title: 'TÀI KHOẢN',
                items: [
                  _MenuItem(
                      icon: Icons.person_outline,
                      label: 'Chỉnh sửa hồ sơ',
                      onTap: () =>
                          _go(context, EditProfileScreen(appState: appState))),
                  _MenuItem(
                      icon: Icons.favorite_border,
                      label: 'Sản phẩm yêu thích',
                      badge: wishCount > 0 ? '$wishCount' : null,
                      onTap: () =>
                          _go(context, WishlistScreen(appState: appState))),
                  _MenuItem(
                      icon: Icons.location_on_outlined,
                      label: 'Địa chỉ giao hàng',
                      onTap: () => _go(context, const AddressBookScreen())),
                  _MenuItem(
                      icon: Icons.payment_outlined,
                      label: 'Phương thức thanh toán',
                      onTap: () => _go(context, const PaymentMethodsScreen())),
                  _MenuItem(
                      icon: Icons.card_giftcard_outlined,
                      label: 'Mã khuyến mãi',
                      onTap: () => _go(context, const PromoCodeScreen())),
                  _MenuItem(
                      icon: Icons.stars_outlined,
                      label: 'Điểm tích lũy (${appState.loyaltyPoints}đ)',
                      onTap: () => _go(context, LoyaltyScreen(appState: appState))),
                ],
              ),

              const SizedBox(height: 8),

              _MenuGroup(
                title: 'CÀI ĐẶT',
                items: [
                  _MenuItem(
                      icon: Icons.notifications_outlined,
                      label: 'Thông báo',
                      onTap: () => _go(context, const NotificationsScreen())),
                  _MenuItem(
                      icon: Icons.lock_outline,
                      label: 'Đổi mật khẩu',
                      onTap: () =>
                          _go(context, const ChangePasswordScreen())),
                  _MenuItem(
                      icon: Icons.language,
                      label: 'Ngôn ngữ',
                      trailing: 'Tiếng Việt',
                      onTap: () => _go(context, const SettingsScreen())),
                  _MenuItem(
                      icon: Icons.dark_mode_outlined,
                      label: 'Giao diện',
                      trailing: 'Sáng',
                      onTap: () => _go(context, const SettingsScreen())),
                  _MenuItem(
                      icon: Icons.help_outline,
                      label: 'Trợ giúp & Hỗ trợ',
                      onTap: () => _go(context, const HelpScreen())),
                  _MenuItem(
                      icon: Icons.info_outline,
                      label: 'Về ứng dụng',
                      trailing: 'v1.0.0',
                      onTap: () => _go(context, const AboutScreen())),
                ],
              ),

              const SizedBox(height: 8),

              Container(
                color: Colors.white,
                child: _MenuItem(
                  icon: Icons.logout,
                  label: 'Đăng xuất',
                  color: AppTheme.discountRed,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen())),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 36, color: const Color(0xFFEEEEEE));
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _StatItem(
      {required this.value,
      required this.label,
      required this.icon,
      this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppTheme.primaryGreen),
              const SizedBox(height: 3),
              Text(value,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryGreen)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 10, color: AppTheme.textGray)),
            ],
          ),
        ),
      );
}

class _MenuGroup extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _MenuGroup({required this.title, required this.items});

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textLight,
                      letterSpacing: 0.8)),
            ),
            ...items,
          ],
        ),
      );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final String? badge;
  final String? trailing;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.badge,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.textDark;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: (color ?? AppTheme.primaryGreen).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon,
                  size: 18, color: color ?? AppTheme.primaryGreen),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 14,
                        color: c,
                        fontWeight: FontWeight.w500))),
            if (badge != null)
              Container(
                margin: const EdgeInsets.only(right: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(badge!,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ),
            if (trailing != null)
              Text(trailing!,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textLight)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right,
                size: 16, color: AppTheme.textLight),
          ],
        ),
      ),
    );
  }
}
