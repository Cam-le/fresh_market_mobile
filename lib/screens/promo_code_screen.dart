import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class _Voucher {
  final String code;
  final String title;
  final String description;
  final String expiry;
  final int discount;
  final bool isPercent;
  final int minOrder;
  bool isUsed;

  _Voucher({
    required this.code,
    required this.title,
    required this.description,
    required this.expiry,
    required this.discount,
    required this.isPercent,
    required this.minOrder,
    this.isUsed = false,
  });
}

class PromoCodeScreen extends StatefulWidget {
  const PromoCodeScreen({super.key});

  @override
  State<PromoCodeScreen> createState() => _PromoCodeScreenState();
}

class _PromoCodeScreenState extends State<PromoCodeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _codeCtrl = TextEditingController();

  final List<_Voucher> _vouchers = [
    _Voucher(
      code: 'WELCOME50',
      title: 'Chào mừng thành viên mới',
      description: 'Giảm 50.000đ cho đơn hàng đầu tiên từ 200.000đ',
      expiry: '31/03/2026',
      discount: 50000,
      isPercent: false,
      minOrder: 200000,
    ),
    _Voucher(
      code: 'FREESHIP',
      title: 'Miễn phí vận chuyển',
      description: 'Miễn phí giao hàng cho mọi đơn hàng không giới hạn',
      expiry: '15/04/2026',
      discount: 25000,
      isPercent: false,
      minOrder: 0,
    ),
    _Voucher(
      code: 'SUMMER20',
      title: 'Khuyến mãi hè 2026',
      description: 'Giảm 20% tối đa 100.000đ cho đơn từ 300.000đ',
      expiry: '30/06/2026',
      discount: 20,
      isPercent: true,
      minOrder: 300000,
    ),
    _Voucher(
      code: 'VIP30',
      title: 'Ưu đãi thành viên VIP',
      description: 'Giảm 30% cho thành viên hạng VIP, đơn từ 500.000đ',
      expiry: '31/12/2026',
      discount: 30,
      isPercent: true,
      minOrder: 500000,
    ),
    _Voucher(
      code: 'OLDCODE',
      title: 'Mã đã hết hạn',
      description: 'Mã này đã hết hạn sử dụng',
      expiry: '01/01/2026',
      discount: 10,
      isPercent: true,
      minOrder: 100000,
      isUsed: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  String _formatPrice(int p) =>
      p
          .toString()
          .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.') +
      '₫';

  List<_Voucher> get _available => _vouchers.where((v) => !v.isUsed).toList();
  List<_Voucher> get _used => _vouchers.where((v) => v.isUsed).toList();

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Đã sao chép mã $code'),
      backgroundColor: AppTheme.primaryGreen,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  void _applyManualCode() {
    final code = _codeCtrl.text.trim().toUpperCase();
    final found =
        _vouchers.where((v) => v.code == code && !v.isUsed).firstOrNull;
    if (found != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('✅ Áp dụng mã $code thành công!'),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
      _codeCtrl.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('❌ Mã không hợp lệ hoặc đã hết hạn'),
        backgroundColor: AppTheme.discountRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
    }
  }

  Widget _buildVoucherCard(_Voucher v) {
    final isGray = v.isUsed;
    final color = isGray ? Colors.grey : AppTheme.primaryGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left accent strip + icon
              Container(
                width: 72,
                color: color.withValues(alpha: 0.12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      v.isPercent ? Icons.percent : Icons.local_offer_outlined,
                      color: color,
                      size: 28,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      v.isPercent
                          ? '-${v.discount}%'
                          : '-${_formatPrice(v.discount)}',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: color),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Dashed separator
              CustomPaint(
                size: const Size(12, double.infinity),
                painter: _DashedLinePainter(color: Colors.grey[300]!),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(v.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isGray
                                      ? AppTheme.textLight
                                      : AppTheme.textDark,
                                )),
                          ),
                          if (isGray)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('Đã dùng',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.grey)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(v.description,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textGray,
                              height: 1.4)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 12, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text('HSD: ${v.expiry}',
                              style: const TextStyle(
                                  fontSize: 11, color: AppTheme.textLight)),
                          const Spacer(),
                          if (!isGray)
                            GestureDetector(
                              onTap: () => _copyCode(v.code),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: color.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(v.code,
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: color)),
                                    const SizedBox(width: 4),
                                    Icon(Icons.copy, size: 12, color: color),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (v.minOrder > 0) ...[
                        const SizedBox(height: 4),
                        Text('Đơn tối thiểu: ${_formatPrice(v.minOrder)}',
                            style: const TextStyle(
                                fontSize: 11, color: AppTheme.textLight)),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mã khuyến mãi'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: 'Khả dụng (${_available.length})'),
            Tab(text: 'Đã dùng (${_used.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Manual input
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      hintText: 'Nhập mã giảm giá...',
                      prefixIcon: Icon(Icons.confirmation_number_outlined,
                          color: AppTheme.textLight),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _applyManualCode,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(80, 52),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text('Áp dụng', style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _available.isEmpty
                    ? const Center(
                        child: Text('Không có mã khuyến mãi',
                            style: TextStyle(color: AppTheme.textGray)))
                    : ListView(
                        padding: const EdgeInsets.all(12),
                        children: _available.map(_buildVoucherCard).toList(),
                      ),
                _used.isEmpty
                    ? const Center(
                        child: Text('Chưa dùng mã nào',
                            style: TextStyle(color: AppTheme.textGray)))
                    : ListView(
                        padding: const EdgeInsets.all(12),
                        children: _used.map(_buildVoucherCard).toList(),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(
          Offset(size.width / 2, y), Offset(size.width / 2, y + 5), paint);
      y += 9;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
