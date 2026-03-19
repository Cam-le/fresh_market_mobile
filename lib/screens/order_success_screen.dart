import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 72,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Đặt hàng thành công!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Đơn hàng của bạn đã được xác nhận.\nChúng tôi sẽ giao hàng trong 2–4 giờ.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.textGray,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Delivery steps
                const _DeliveryStep(
                  icon: Icons.check_circle,
                  label: 'Đơn hàng đã xác nhận',
                  isCompleted: true,
                ),
                const _DeliveryStep(
                  icon: Icons.inventory_2_outlined,
                  label: 'Đang chuẩn bị hàng',
                  isActive: true,
                ),
                const _DeliveryStep(
                  icon: Icons.local_shipping_outlined,
                  label: 'Đang giao hàng',
                ),
                const _DeliveryStep(
                  icon: Icons.home_outlined,
                  label: 'Giao hàng thành công',
                  isLast: true,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 54)),
                    child: const Text('Về trang chủ',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                  child: const Text(
                    'Xem đơn hàng',
                    style: TextStyle(
                        color: AppTheme.primaryGreen,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeliveryStep extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isCompleted;
  final bool isActive;
  final bool isLast;

  const _DeliveryStep({
    required this.icon,
    required this.label,
    this.isCompleted = false,
    this.isActive = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCompleted
        ? AppTheme.primaryGreen
        : isActive
            ? AppTheme.accentOrange
            : const Color(0xFFE0E0E0);

    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            if (!isLast)
              Container(
                  width: 2,
                  height: 28,
                  color: isCompleted
                      ? AppTheme.primaryGreen
                      : const Color(0xFFE0E0E0)),
          ],
        ),
        const SizedBox(width: 14),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isCompleted
                ? AppTheme.textDark
                : isActive
                    ? AppTheme.accentOrange
                    : AppTheme.textLight,
            fontWeight:
                isCompleted || isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
