import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_screen.dart';

class CartBottomSheet extends StatelessWidget {
  final AppState appState;

  const CartBottomSheet({super.key, required this.appState});

  static void show(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CartBottomSheet(appState: appState),
    );
  }

  String _fmt(double p) =>
      '${p.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.')}₫';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (ctx, _) {
        final cart = appState.cart;
        final items = cart.items;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    Text(
                      'Giỏ hàng (${cart.itemCount})',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => CartScreen(appState: appState)),
                      ),
                      child: const Text('Xem tất cả',
                          style: TextStyle(
                              color: AppTheme.primaryGreen, fontSize: 13)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Items
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          size: 48, color: AppTheme.textLight),
                      SizedBox(height: 8),
                      Text('Giỏ hàng trống',
                          style: TextStyle(
                              color: AppTheme.textGray, fontSize: 15)),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: items
                        .map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item.product.imageUrl,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                          width: 56,
                                          height: 56,
                                          color: const Color(0xFFE8F5E9)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(item.product.name,
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis),
                                        Text(
                                            '${item.product.unit} × ${item.quantity}',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: AppTheme.textLight)),
                                      ],
                                    ),
                                  ),
                                  Text(_fmt(item.subtotal),
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.primaryGreen)),
                                  const SizedBox(width: 8),
                                  // Quick remove
                                  GestureDetector(
                                    onTap: () =>
                                        appState.cart.remove(item.product.id),
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF5F5F5),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(Icons.close,
                                          size: 14, color: AppTheme.textLight),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              // Summary + checkout button
              if (items.isNotEmpty) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text('Tạm tính',
                              style: TextStyle(color: AppTheme.textGray)),
                          const Spacer(),
                          Text(_fmt(cart.subtotal),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      if (cart.shippingFee == 0) ...[
                        const SizedBox(height: 4),
                        const Row(
                          children: [
                            Text('Phí vận chuyển',
                                style: TextStyle(color: AppTheme.textGray)),
                            Spacer(),
                            Text('Miễn phí',
                                style: TextStyle(
                                    color: AppTheme.primaryGreen,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tổng cộng',
                                  style: TextStyle(
                                      fontSize: 13, color: AppTheme.textGray)),
                              Text(_fmt(cart.total),
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.primaryGreen)),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          CheckoutScreen(appState: appState)),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 52)),
                              child: const Text('Đặt hàng ngay',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
