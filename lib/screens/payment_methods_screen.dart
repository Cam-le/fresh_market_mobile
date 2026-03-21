import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class _PaymentMethod {
  final String id;
  final String type;
  final String label;
  final String last4;
  final String expiry;
  final Color color;
  bool isDefault;

  _PaymentMethod({
    required this.id,
    required this.type,
    required this.label,
    required this.last4,
    required this.expiry,
    required this.color,
    this.isDefault = false,
  });
}

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<_PaymentMethod> _methods = [
    _PaymentMethod(
      id: '1',
      type: 'visa',
      label: 'Visa',
      last4: '4242',
      expiry: '12/27',
      color: const Color(0xFF1A1F71),
      isDefault: true,
    ),
    _PaymentMethod(
      id: '2',
      type: 'mastercard',
      label: 'Mastercard',
      last4: '8888',
      expiry: '06/26',
      color: const Color(0xFFEB001B),
    ),
    _PaymentMethod(
      id: '3',
      type: 'momo',
      label: 'Ví MoMo',
      last4: '7890',
      expiry: '',
      color: const Color(0xFFAE2070),
    ),
  ];

  void _showAddCard() {
    final numberCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final expiryCtrl = TextEditingController();
    final cvvCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Thêm thẻ mới',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            // Card number
            TextField(
              controller: numberCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
                _CardNumberFormatter(),
              ],
              decoration: const InputDecoration(
                labelText: 'Số thẻ',
                hintText: '1234 5678 9012 3456',
                prefixIcon: Icon(Icons.credit_card_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: nameCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Tên chủ thẻ',
                hintText: 'NGUYEN VAN A',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: expiryCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                      _ExpiryFormatter(),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'MM/YY',
                      hintText: '12/27',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: cvvCtrl,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'CVV',
                      hintText: '***',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _methods.add(_PaymentMethod(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        type: 'visa',
                        label: 'Visa',
                        last4: numberCtrl.text.length >= 4
                            ? numberCtrl.text
                                .substring(numberCtrl.text.length - 4)
                            : '0000',
                        expiry: expiryCtrl.text,
                        color: const Color(0xFF1A1F71),
                      )));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('✅ Đã thêm thẻ thành công'),
                    backgroundColor: AppTheme.primaryGreen,
                    behavior: SnackBarBehavior.floating,
                  ));
                },
                child: const Text('Thêm thẻ',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phương thức thanh toán')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Cards
          ..._methods.map((m) => _CardTile(
                method: m,
                onSetDefault: () => setState(() {
                  for (final x in _methods) {
                    x.isDefault = false;
                  }
                  m.isDefault = true;
                }),
                onDelete: () => setState(() => _methods.remove(m)),
              )),
          const SizedBox(height: 12),
          // COD option
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: const Row(
              children: [
                Icon(Icons.money, color: AppTheme.primaryGreen, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tiền mặt khi nhận hàng',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      Text('Thanh toán trực tiếp cho shipper',
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.textGray)),
                    ],
                  ),
                ),
                Icon(Icons.check_circle,
                    color: AppTheme.primaryGreen, size: 22),
              ],
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _showAddCard,
            icon: const Icon(Icons.add, color: AppTheme.primaryGreen),
            label: const Text('Thêm thẻ / ví điện tử',
                style: TextStyle(
                    color: AppTheme.primaryGreen, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              side: const BorderSide(color: AppTheme.primaryGreen),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  final _PaymentMethod method;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const _CardTile({
    required this.method,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [method.color, method.color.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(method.label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  const Spacer(),
                  if (method.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Mặc định',
                          style: TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz, color: Colors.white),
                    onSelected: (v) {
                      if (v == 'default') onSetDefault();
                      if (v == 'delete') onDelete();
                    },
                    itemBuilder: (_) => [
                      if (!method.isDefault)
                        const PopupMenuItem(
                            value: 'default', child: Text('Đặt làm mặc định')),
                      const PopupMenuItem(
                          value: 'delete', child: Text('Xoá thẻ')),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '**** **** **** ${method.last4}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2),
              ),
              const SizedBox(height: 4),
              if (method.expiry.isNotEmpty)
                Text('Hết hạn: ${method.expiry}',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue val) {
    final text = val.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }
    return val.copyWith(text: buffer.toString());
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue val) {
    final text = val.text;
    if (text.length == 2 && old.text.length == 1) {
      return val.copyWith(text: '$text/');
    }
    return val;
  }
}
