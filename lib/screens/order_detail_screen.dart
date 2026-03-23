import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/order.dart';
import '../models/cart.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import 'order_tracking_screen.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;
  final AppState? appState;

  const OrderDetailScreen({super.key, required this.order, this.appState});

  String _fmt(double p) =>
      '${p.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.')}₫';

  String _fmtDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return const Color(0xFF1E88E5);
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
    final statusColor = _statusColor(order.status);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: 'Đơn hàng ${order.id}'));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Đã sao chép mã đơn hàng'),
                behavior: SnackBarBehavior.floating,
              ));
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // ── Status card ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: statusColor.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle),
                  child: Icon(_statusIcon(order.status),
                      color: statusColor, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.statusLabel,
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: statusColor)),
                      Text(_fmtDate(order.createdAt),
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textGray)),
                    ],
                  ),
                ),
                if (order.status == OrderStatus.delivering)
                  TextButton.icon(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => OrderTrackingScreen(
                                order: order, appState: appState))),
                    icon: const Icon(Icons.gps_fixed, size: 14),
                    label:
                        const Text('Theo dõi', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(foregroundColor: statusColor),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Order info ─────────────────────────────────────────────
          _Card(
            child: Column(
              children: [
                _InfoRow('Mã đơn hàng', order.id, copyable: true),
                const Divider(height: 20),
                _InfoRow('Ngày đặt', _fmtDate(order.createdAt)),
                const Divider(height: 20),
                _InfoRow('Trạng thái', order.statusLabel,
                    valueColor: statusColor),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Delivery address ───────────────────────────────────────
          _Card(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.location_on_outlined,
                      color: AppTheme.primaryGreen, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Địa chỉ giao hàng',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(order.address,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textGray,
                              height: 1.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Products ───────────────────────────────────────────────
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Sản phẩm đặt hàng',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text('${order.items.length} sản phẩm',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textGray)),
                  ],
                ),
                const SizedBox(height: 14),
                ...order.items.map((item) => _ItemRow(item: item, fmt: _fmt)),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Payment summary ────────────────────────────────────────
          _Card(
            child: Column(
              children: [
                _InfoRow(
                    'Tạm tính',
                    _fmt(order.total - 25000 > 0
                        ? order.total - 0
                        : order.total)),
                const Divider(height: 16),
                const _InfoRow('Phí giao hàng', 'Miễn phí',
                    valueColor: AppTheme.primaryGreen),
                const Divider(height: 16),
                const _InfoRow('Phương thức TT', 'Tiền mặt (COD)'),
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider()),
                Row(
                  children: [
                    const Text('Tổng thanh toán',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    Text(_fmt(order.total),
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryGreen)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Actions ────────────────────────────────────────────────
          if (order.status == OrderStatus.delivered)
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      appState?.reorder(order);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã thêm sản phẩm vào giỏ hàng'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.replay, size: 18),
                    label: const Text('Mua lại',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => _showReviewDialog(context),
                    icon: const Icon(Icons.star_outline, size: 18),
                    label: const Text('Đánh giá sản phẩm',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryGreen,
                      side: const BorderSide(color: AppTheme.primaryGreen),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),

          if (order.status == OrderStatus.confirmed)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => _confirmCancel(context),
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: const Text('Huỷ đơn hàng',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.discountRed,
                  side: const BorderSide(color: AppTheme.discountRed),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  IconData _statusIcon(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return Icons.access_time;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.delivering:
        return Icons.local_shipping_outlined;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Huỷ đơn hàng?'),
        content: const Text('Bạn có chắc muốn huỷ đơn hàng này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () {
              appState?.cancelOrder(order.id);
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã huỷ đơn hàng'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.discountRed),
            child: const Text('Xác nhận huỷ',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(BuildContext context) {
    int rating = 5;
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: const Text('Đánh giá sản phẩm'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Chọn số sao:', style: TextStyle(fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    5,
                    (i) => GestureDetector(
                          onTap: () => setDlg(() => rating = i + 1),
                          child: Icon(
                            i < rating ? Icons.star : Icons.star_border,
                            color: AppTheme.accentOrange,
                            size: 32,
                          ),
                        )),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Nhận xét của bạn...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(10),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cảm ơn bạn đã đánh giá!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Gửi đánh giá'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)
          ],
        ),
        child: child,
      );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool copyable;

  const _InfoRow(this.label, this.value,
      {this.valueColor, this.copyable = false});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(label,
              style: const TextStyle(fontSize: 13, color: AppTheme.textGray)),
          const Spacer(),
          if (copyable)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Đã sao chép'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 1),
                ));
              },
              child: Row(children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: valueColor ?? AppTheme.textDark)),
                const SizedBox(width: 4),
                const Icon(Icons.copy, size: 13, color: AppTheme.textLight),
              ]),
            )
          else
            Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppTheme.textDark)),
        ],
      );
}

class _ItemRow extends StatelessWidget {
  final CartItem item;
  final String Function(double) fmt;

  const _ItemRow({required this.item, required this.fmt});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(item.product.imageUrl,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      width: 52, height: 52, color: const Color(0xFFE8F5E9))),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.product.name,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text('${item.product.unit}  ×  ${item.quantity}',
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textLight)),
                ],
              ),
            ),
            Text(fmt(item.subtotal),
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryGreen)),
          ],
        ),
      );
}
