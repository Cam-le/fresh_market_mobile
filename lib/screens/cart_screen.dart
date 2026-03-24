import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../models/cart.dart';
import '../theme/app_theme.dart';
import 'checkout_screen.dart';
import 'promo_code_screen.dart';

class CartScreen extends StatefulWidget {
  final AppState appState;

  const CartScreen({super.key, required this.appState});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String _formatPrice(num price) {
    final formatted = price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+$)'),
          (m) => '${m[1]}.',
        );
    return '$formatted₫';
  }

  void _openVoucherPicker(CartModel cart) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PromoCodeScreen(
          cartSubtotal: cart.subtotal,
          onApply: (voucher) {
            final amount = voucher.computeDiscount(cart.subtotal).toDouble();
            cart.applyDiscount(code: voucher.code, amount: amount);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        final cart = widget.appState.cart;
        final items = cart.items;

        return Scaffold(
          appBar: AppBar(
            title: Text('Giỏ hàng (${cart.itemCount})'),
            actions: [
              if (items.isNotEmpty)
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Xoá tất cả?'),
                        content: const Text(
                          'Bạn có chắc muốn xoá tất cả sản phẩm trong giỏ?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Huỷ'),
                          ),
                          TextButton(
                            onPressed: () {
                              cart.clear();
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Xoá',
                              style: TextStyle(color: AppTheme.discountRed),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text(
                    'Xoá tất cả',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
            ],
          ),
          body: items.isEmpty ? _buildEmptyCart() : _buildCartList(items, cart),
          bottomNavigationBar: items.isEmpty ? null : _buildCheckoutBar(cart),
        );
      },
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Giỏ hàng trống',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textGray,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hãy thêm sản phẩm vào giỏ hàng',
            style: TextStyle(fontSize: 14, color: AppTheme.textLight),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(180, 48),
            ),
            child: const Text('Mua sắm ngay'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(List<CartItem> items, CartModel cart) {
    // FIX: compute remaining as double explicitly to avoid num type error
    final double remaining = (200000.0 - cart.subtotal).clamp(0.0, 200000.0);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Free shipping progress
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.local_shipping_outlined,
                    size: 18,
                    color: AppTheme.primaryGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cart.shippingFee == 0
                          ? '🎉 Bạn được miễn phí giao hàng!'
                          : 'Mua thêm ${_formatPrice(remaining)} để được miễn phí giao hàng',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (cart.subtotal / 200000.0).clamp(0.0, 1.0),
                  backgroundColor: Colors.white,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryGreen,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),

        ...items.map(
          (item) => _CartItemCard(
            item: item,
            onIncrement: () => setState(() => cart.add(item.product)),
            onDecrement: () => setState(() => cart.decrement(item.product.id)),
            onRemove: () => setState(() => cart.remove(item.product.id)),
            formatPrice: _formatPrice,
          ),
        ),

        const SizedBox(height: 12),

        // Order summary
        Container(
          padding: const EdgeInsets.all(16),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tóm tắt đơn hàng',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              _SummaryRow('Tạm tính', _formatPrice(cart.subtotal)),
              const SizedBox(height: 8),
              _SummaryRow(
                'Phí giao hàng',
                cart.shippingFee == 0
                    ? 'Miễn phí'
                    : _formatPrice(cart.shippingFee),
                valueColor:
                    cart.shippingFee == 0 ? AppTheme.primaryGreen : null,
              ),
              const SizedBox(height: 10),
              // Voucher row
              GestureDetector(
                onTap: () => _openVoucherPicker(cart),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: cart.appliedVoucherCode != null
                          ? AppTheme.primaryGreen
                          : const Color(0xFFE0E0E0),
                      width: cart.appliedVoucherCode != null ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: cart.appliedVoucherCode != null
                        ? const Color(0xFFE8F5E9)
                        : Colors.white,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.confirmation_number_outlined,
                        size: 18,
                        color: cart.appliedVoucherCode != null
                            ? AppTheme.primaryGreen
                            : AppTheme.textLight,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: cart.appliedVoucherCode != null
                            ? Text(
                                cart.appliedVoucherCode!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryGreen,
                                ),
                              )
                            : const Text(
                                'Chọn hoặc nhập mã giảm giá',
                                style: TextStyle(
                                    fontSize: 13, color: AppTheme.textLight),
                              ),
                      ),
                      if (cart.appliedVoucherCode != null)
                        GestureDetector(
                          onTap: cart.clearDiscount,
                          child: const Icon(Icons.close,
                              size: 16, color: AppTheme.textGray),
                        )
                      else
                        const Icon(Icons.chevron_right,
                            size: 18, color: AppTheme.textLight),
                    ],
                  ),
                ),
              ),
              if (cart.discount > 0) ...[
                const SizedBox(height: 8),
                _SummaryRow(
                  'Giảm giá',
                  '-${_formatPrice(cart.discount)}',
                  valueColor: AppTheme.discountRed,
                ),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(),
              ),
              _SummaryRow(
                'Tổng cộng',
                _formatPrice(cart.total),
                isBold: true,
                valueColor: AppTheme.primaryGreen,
              ),
            ],
          ),
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildCheckoutBar(CartModel cart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tổng cộng',
                style: TextStyle(fontSize: 12, color: AppTheme.textGray),
              ),
              Text(
                _formatPrice(cart.total),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CheckoutScreen(appState: widget.appState),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 52),
              ),
              child: const Text(
                'Đặt hàng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;
  final String Function(num) formatPrice;

  const _CartItemCard({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
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
      child: Row(
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.product.imageUrl,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 72,
                height: 72,
                color: const Color(0xFFE8F5E9),
                child: const Icon(
                  Icons.image_not_supported,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.product.unit,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      formatPrice(item.product.price),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const Spacer(),
                    _QuantityControl(
                      quantity: item.quantity,
                      onDecrement: onDecrement,
                      onIncrement: onIncrement,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Remove
          IconButton(
            onPressed: onRemove,
            icon: const Icon(
              Icons.close,
              size: 18,
              color: AppTheme.textLight,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
        ],
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantityControl({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onDecrement,
            child: Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              child: const Icon(
                Icons.remove,
                size: 14,
                color: AppTheme.primaryGreen,
              ),
            ),
          ),
          Container(
            width: 28,
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          GestureDetector(
            onTap: onIncrement,
            child: Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              child: const Icon(
                Icons.add,
                size: 14,
                color: AppTheme.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow(
    this.label,
    this.value, {
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textGray,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}
