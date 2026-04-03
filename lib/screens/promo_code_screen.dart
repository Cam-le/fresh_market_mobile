import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/app_data.dart';
import '../theme/app_theme.dart';

// Internal display wrapper — merges voucher list with used-state tracking.
class _VoucherItem {
  final PromoVoucher voucher;
  bool isUsed;

  _VoucherItem({required this.voucher, this.isUsed = false});
}

class PromoCodeScreen extends StatefulWidget {
  /// When provided, the screen runs in "picker" mode:
  /// - Each eligible voucher shows an "Áp dụng" button instead of copy.
  /// - Tapping it calls [onApply] and pops.
  /// - Ineligible vouchers (minOrder not met) are shown dimmed.
  final double? cartSubtotal;
  final void Function(PromoVoucher voucher)? onApply;

  /// Optional pre-loaded voucher list (e.g. from API). Falls back to
  /// [AppData.vouchers] when null or empty.
  final List<PromoVoucher>? availableVouchers;

  const PromoCodeScreen({
    super.key,
    this.cartSubtotal,
    this.onApply,
    this.availableVouchers,
  });

  bool get _isPickerMode => onApply != null;

  @override
  State<PromoCodeScreen> createState() => _PromoCodeScreenState();
}

class _PromoCodeScreenState extends State<PromoCodeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _codeCtrl = TextEditingController();

  late final List<_VoucherItem> _items;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Use caller-supplied list if provided, otherwise fall back to AppData.
    final source = (widget.availableVouchers?.isNotEmpty == true)
        ? widget.availableVouchers!
        : AppData.vouchers;

    _items = [
      ...source.map((v) => _VoucherItem(voucher: v)),
      // One static expired code kept as "used" example.
      _VoucherItem(
        voucher: const PromoVoucher(
          code: 'OLDCODE',
          title: 'Mã đã hết hạn',
          description: 'Mã này đã hết hạn sử dụng',
          expiry: '01/01/2026',
          discount: 10,
          isPercent: true,
          minOrder: 100000,
        ),
        isUsed: true,
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  String _formatPrice(int p) =>
      '${p.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.')}₫';

  List<_VoucherItem> get _available => _items.where((v) => !v.isUsed).toList();
  List<_VoucherItem> get _used => _items.where((v) => v.isUsed).toList();

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

  void _applyVoucher(PromoVoucher v) {
    widget.onApply!(v);
    Navigator.pop(context);
  }

  void _applyManualCode() {
    final code = _codeCtrl.text.trim().toUpperCase();
    final found =
        _items.where((v) => v.voucher.code == code && !v.isUsed).firstOrNull;
    if (found != null) {
      if (widget._isPickerMode) {
        _applyVoucher(found.voucher);
        _codeCtrl.clear();
        return;
      }
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

  Widget _buildVoucherCard(_VoucherItem item) {
    final v = item.voucher;
    final isGray = item.isUsed;
    final subtotal = widget.cartSubtotal ?? 0;
    final meetsMin = subtotal >= v.minOrder;
    final isDisabled = widget._isPickerMode && !isGray && !meetsMin;
    final color = (isGray || isDisabled) ? Colors.grey : AppTheme.primaryGreen;

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)
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
                        v.isPercent
                            ? Icons.percent
                            : Icons.local_offer_outlined,
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
                            if (!isGray) ...[
                              if (widget._isPickerMode)
                                _ApplyButton(
                                  color: color,
                                  enabled: meetsMin,
                                  onTap:
                                      meetsMin ? () => _applyVoucher(v) : null,
                                )
                              else
                                GestureDetector(
                                  onTap: () => _copyCode(v.code),
                                  child: _CodeChip(code: v.code, color: color),
                                ),
                            ],
                          ],
                        ),
                        if (v.minOrder > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            isDisabled
                                ? 'Cần thêm ${_formatPrice((v.minOrder - subtotal).round())} để dùng mã này'
                                : 'Đơn tối thiểu: ${_formatPrice(v.minOrder)}',
                            style: TextStyle(
                                fontSize: 11,
                                color: isDisabled
                                    ? AppTheme.accentOrange
                                    : AppTheme.textLight),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget._isPickerMode ? 'Chọn mã giảm giá' : 'Mã khuyến mãi'),
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

// ── Small reusable sub-widgets ────────────────────────────────────────────

class _CodeChip extends StatelessWidget {
  final String code;
  final Color color;
  const _CodeChip({required this.code, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(code,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(width: 4),
          Icon(Icons.copy, size: 12, color: color),
        ],
      ),
    );
  }
}

class _ApplyButton extends StatelessWidget {
  final Color color;
  final bool enabled;
  final VoidCallback? onTap;
  const _ApplyButton({required this.color, required this.enabled, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: enabled ? color : Colors.grey[300],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Áp dụng',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: enabled ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});

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
