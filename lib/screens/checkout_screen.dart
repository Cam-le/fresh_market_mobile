import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final AppState appState;

  const CheckoutScreen({super.key, required this.appState});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _nameController = TextEditingController(text: 'Nguyễn Văn A');
  final _phoneController = TextEditingController(text: '0901 234 567');
  final _addressController =
      TextEditingController(text: '123 Nguyễn Huệ, Q.1, TP.HCM');
  final _noteController = TextEditingController();

  int _selectedPayment = 0;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'icon': Icons.money, 'label': 'Tiền mặt khi nhận hàng', 'sub': 'COD'},
    {
      'icon': Icons.credit_card,
      'label': 'Thẻ tín dụng / Ghi nợ',
      'sub': 'Visa, Mastercard'
    },
    {
      'icon': Icons.account_balance_wallet,
      'label': 'Ví điện tử',
      'sub': 'MoMo, ZaloPay, VNPay'
    },
  ];

  String _formatPrice(num price) {
    final formatted = price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+$)'),
          (m) => '${m[1]}.',
        );
    return '$formatted₫';
  }

  Future<void> _placeOrder() async {
    // Capture before async gap
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isLoading = true);

    final address =
        '${_nameController.text} • ${_phoneController.text} • ${_addressController.text}';

    try {
      await widget.appState.placeOrder(
        address,
        paymentMethodIndex: _selectedPayment,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
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
                if (cart.discount > 0) ...[
                  const SizedBox(height: 8),
                  _Row(
                    cart.appliedVoucherCode != null
                        ? 'Mã "${cart.appliedVoucherCode}"'
                        : 'Giảm giá',
                    '-${_formatPrice(cart.discount)}',
                    valueColor: AppTheme.discountRed,
                  ),
                ],
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider()),
                _Row('Tổng thanh toán', _formatPrice(cart.total),
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
              : Text('Đặt hàng • ${_formatPrice(cart.total)}',
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
