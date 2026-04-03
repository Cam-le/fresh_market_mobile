import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../data/app_data.dart';
import '../services/voucher_service.dart';
import '../theme/app_theme.dart';
import 'order_success_screen.dart';
import 'promo_code_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final AppState appState;

  const CheckoutScreen({super.key, required this.appState});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  final _noteController = TextEditingController();

  int _selectedPayment = 0;
  bool _isLoading = false;

  // Voucher state
  PromoVoucher? _appliedVoucher;
  List<PromoVoucher> _availableVouchers = [];
  bool _vouchersLoaded = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'icon': Icons.money, 'label': 'Tiền mặt khi nhận hàng', 'sub': 'COD'},
    {
      'icon': Icons.account_balance_wallet_outlined,
      'label': 'VNPay',
      'sub': 'Thanh toán qua cổng VNPay'
    },
  ];

  @override
  void initState() {
    super.initState();
    final u = widget.appState.user;
    _nameController = TextEditingController(text: u.name);
    _phoneController = TextEditingController(text: u.phone);
    _addressController = TextEditingController(text: u.city);
    _loadVouchers();
  }

  Future<void> _loadVouchers() async {
    final vouchers = await VoucherService.fetchAll();
    if (!mounted) return;
    setState(() {
      _availableVouchers = vouchers;
      _vouchersLoaded = true;
    });
  }

  String _formatPrice(num price) {
    final formatted = price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+$)'),
          (m) => '${m[1]}.',
        );
    return '$formatted₫';
  }

  double get _discountAmount {
    if (_appliedVoucher == null) return 0;
    final v = _appliedVoucher!;
    final sub = widget.appState.cart.subtotal;
    if (v.isPercent) return sub * v.discount / 100;
    return v.discount.toDouble();
  }

  double get _orderTotal {
    final cart = widget.appState.cart;
    return (cart.subtotal + cart.shippingFee - _discountAmount)
        .clamp(0, double.infinity);
  }

  Future<void> _openVoucherPicker() async {
    final vouchers = _vouchersLoaded && _availableVouchers.isNotEmpty
        ? _availableVouchers
        : AppData.vouchers;

    if (!mounted) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => PromoCodeScreen(
          cartSubtotal: widget.appState.cart.subtotal,
          availableVouchers: vouchers,
          onApply: (v) {
            setState(() => _appliedVoucher = v);
            widget.appState.cart.applyDiscount(
              code: v.code,
              amount: v.isPercent
                  ? widget.appState.cart.subtotal * v.discount / 100
                  : v.discount.toDouble(),
            );
          },
        ),
      ),
    );
  }

  void _removeVoucher() {
    setState(() => _appliedVoucher = null);
    widget.appState.cart.clearDiscount();
  }

  Future<void> _placeOrder() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isLoading = true);

    try {
      await widget.appState.placeOrder(
        _addressController.text.trim(),
        shippingName: _nameController.text.trim(),
        shippingPhone: _phoneController.text.trim(),
        paymentMethodIndex: _selectedPayment,
        voucherIds: _appliedVoucher?.id != null && _appliedVoucher!.id != 0
            ? [_appliedVoucher!.id]
            : [],
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(appState: widget.appState),
        ),
        (route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Đặt hàng thất bại, vui lòng thử lại'),
          backgroundColor: AppTheme.discountRed,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = widget.appState.cart;

    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            title: 'Địa chỉ giao hàng',
            icon: Icons.location_on_outlined,
            child: Column(
              children: [
                _buildTextField(
                    'Họ và tên', _nameController, Icons.person_outline),
                const SizedBox(height: 12),
                _buildTextField(
                    'Số điện thoại', _phoneController, Icons.phone_outlined,
                    type: TextInputType.phone),
                const SizedBox(height: 12),
                _buildTextField(
                    'Địa chỉ', _addressController, Icons.home_outlined,
                    maxLines: 2),
                const SizedBox(height: 12),
                _buildTextField(
                    'Ghi chú (tuỳ chọn)', _noteController, Icons.note_outlined,
                    maxLines: 2),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Voucher row ────────────────────────────────────────────────────
          _SectionCard(
            title: 'Mã giảm giá',
            icon: Icons.confirmation_number_outlined,
            child: _appliedVoucher == null
                ? GestureDetector(
                    onTap: _openVoucherPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color:
                                AppTheme.primaryGreen.withValues(alpha: 0.4)),
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFFE8F5E9),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add_circle_outline,
                              color: AppTheme.primaryGreen, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Chọn mã giảm giá',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Icon(Icons.chevron_right,
                              color: AppTheme.primaryGreen, size: 18),
                        ],
                      ),
                    ),
                  )
                : Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppTheme.primaryGreen, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _appliedVoucher!.code,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryGreen),
                            ),
                            Text(
                              '-${_formatPrice(_discountAmount)}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.discountRed,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _removeVoucher,
                        child: const Icon(Icons.close,
                            color: AppTheme.textGray, size: 18),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 16),

          _SectionCard(
            title: 'Phương thức thanh toán',
            icon: Icons.payment_outlined,
            child: Column(
              children: List.generate(_paymentMethods.length, (i) {
                final method = _paymentMethods[i];
                return GestureDetector(
                  onTap: () => setState(() => _selectedPayment = i),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedPayment == i
                            ? AppTheme.primaryGreen
                            : const Color(0xFFE0E0E0),
                        width: _selectedPayment == i ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: _selectedPayment == i
                          ? const Color(0xFFE8F5E9)
                          : Colors.white,
                    ),
                    child: Row(
                      children: [
                        Icon(method['icon'] as IconData,
                            color: _selectedPayment == i
                                ? AppTheme.primaryGreen
                                : AppTheme.textGray,
                            size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(method['label'] as String,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                              Text(method['sub'] as String,
                                  style: const TextStyle(
                                      fontSize: 12, color: AppTheme.textLight)),
                            ],
                          ),
                        ),
                        if (_selectedPayment == i)
                          const Icon(Icons.check_circle,
                              color: AppTheme.primaryGreen, size: 22),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Sản phẩm đặt hàng',
            icon: Icons.shopping_bag_outlined,
            child: Column(
              children: cart.items
                  .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                item.product.imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                    width: 50,
                                    height: 50,
                                    color: const Color(0xFFE8F5E9)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                            Text(_formatPrice(item.subtotal),
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryGreen)),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)
              ],
            ),
            child: Column(
              children: [
                _Row('Tạm tính', _formatPrice(cart.subtotal)),
                const SizedBox(height: 8),
                _Row(
                    'Phí giao hàng',
                    cart.shippingFee == 0
                        ? 'Miễn phí'
                        : _formatPrice(cart.shippingFee),
                    valueColor:
                        cart.shippingFee == 0 ? AppTheme.primaryGreen : null),
                if (_discountAmount > 0) ...[
                  const SizedBox(height: 8),
                  _Row(
                    'Mã "${_appliedVoucher!.code}"',
                    '-${_formatPrice(_discountAmount)}',
                    valueColor: AppTheme.discountRed,
                  ),
                ],
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider()),
                _Row('Tổng thanh toán', _formatPrice(_orderTotal),
                    isBold: true, valueColor: AppTheme.primaryGreen),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, -3))
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _placeOrder,
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56)),
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : Text('Đặt hàng • ${_formatPrice(_orderTotal)}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon,
      {TextInputType type = TextInputType.text, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: type,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: AppTheme.textGray),
        prefixIcon: Icon(icon, size: 18, color: AppTheme.textLight),
        floatingLabelStyle: const TextStyle(color: AppTheme.primaryGreen),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard(
      {required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primaryGreen),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _Row(this.label, this.value, {this.isBold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14,
                color: AppTheme.textGray,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.normal)),
        const Spacer(),
        Text(value,
            style: TextStyle(
                fontSize: isBold ? 16 : 14,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                color: valueColor ?? AppTheme.textDark)),
      ],
    );
  }
}
