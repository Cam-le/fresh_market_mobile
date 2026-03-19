import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../models/order.dart';
import '../theme/app_theme.dart';
import 'order_detail_screen.dart';
// order_tracking_screen is accessed via order_detail_screen, not needed here directly

class OrdersScreen extends StatelessWidget {
  final AppState appState;

  const OrdersScreen({super.key, required this.appState});

  String _formatPrice(double price) {
    final formatted = price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+$)'),
          (m) => '${m[1]}.',
        );
    return '$formatted₫';
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}  '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.delivering:
        return AppTheme.accentOrange;
      case OrderStatus.delivered:
        return AppTheme.primaryGreen;
      case OrderStatus.cancelled:
        return AppTheme.discountRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final orders = appState.orders;
        return Scaffold(
          appBar: AppBar(title: const Text('Đơn hàng của tôi')),
          body: orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 72,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Chưa có đơn hàng nào',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textGray,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: orders.length,
                  itemBuilder: (context, i) {
                    final order = orders[i];
                    // FIX: wrap Container in GestureDetector correctly —
                    // Container has no onTap; GestureDetector does.
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderDetailScreen(order: order),
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Header
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          order.id,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _formatDate(order.createdAt),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppTheme.textLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _statusColor(order.status)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: _statusColor(order.status)
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      order.statusLabel,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: _statusColor(order.status),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            // Items preview
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                children: order.items
                                    .take(2)
                                    .map(
                                      (item) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              child: Image.network(
                                                item.product.imageUrl,
                                                width: 44,
                                                height: 44,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Container(
                                                  width: 44,
                                                  height: 44,
                                                  color: const Color(
                                                    0xFFE8F5E9,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                item.product.name,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              '×${item.quantity}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: AppTheme.textLight,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                            if (order.items.length > 2)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 14,
                                  bottom: 10,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '+${order.items.length - 2} sản phẩm khác',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textLight,
                                    ),
                                  ),
                                ),
                              ),
                            const Divider(height: 1),
                            // Total + action buttons
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  const Text(
                                    'Tổng:',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textGray,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatPrice(order.total),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.primaryGreen,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (order.status == OrderStatus.delivered)
                                    OutlinedButton(
                                      onPressed: () {},
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppTheme.primaryGreen,
                                        side: const BorderSide(
                                          color: AppTheme.primaryGreen,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                        minimumSize: Size.zero,
                                      ),
                                      child: const Text(
                                        'Mua lại',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  if (order.status == OrderStatus.confirmed)
                                    OutlinedButton(
                                      onPressed: () {},
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppTheme.discountRed,
                                        side: const BorderSide(
                                          color: AppTheme.discountRed,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                        minimumSize: Size.zero,
                                      ),
                                      child: const Text(
                                        'Huỷ',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
