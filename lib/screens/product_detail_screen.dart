import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/product_reviews.dart';
import '../widgets/app_footer.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final AppState appState;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.appState,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _descExpanded = false;

  String _formatPrice(double price) {
    final formatted = price
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');
    return '$formatted₫';
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final isWishlisted = widget.appState.wishlist.contains(p.id);
    final cartQty = widget.appState.cart.quantityOf(p.id);

    return Scaffold(
      backgroundColor: Colors.white,
      // ── Sticky bottom bar ──────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, -3))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: Icon(
                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                  color: isWishlisted ? Colors.red : AppTheme.textGray,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => widget.appState.wishlist.toggle(p)),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _QtyButton(
                    icon: Icons.remove,
                    onTap: () {
                      if (_quantity > 1) setState(() => _quantity--);
                    },
                  ),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '$_quantity',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                  _QtyButton(
                    icon: Icons.add,
                    onTap: () => setState(() => _quantity++),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  for (int i = 0; i < _quantity; i++) {
                    widget.appState.cart.add(p);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã thêm $_quantity x ${p.name} vào giỏ'),
                      backgroundColor: AppTheme.primaryGreen,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      action: SnackBarAction(
                        label: 'Xem giỏ',
                        textColor: Colors.white,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart_outlined, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      cartQty > 0 ? 'Thêm vào giỏ ($cartQty)' : 'Thêm vào giỏ',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // ── Scrollable body ────────────────────────────────────────────
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image
            Stack(
              children: [
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: Image.network(
                    p.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 300,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF75B06F), Color(0xFF3D6B27)],
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.eco,
                                size: 72, color: Colors.white54),
                            const SizedBox(height: 8),
                            Text(
                              p.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (p.isSale && p.discountPercent > 0)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.discountRed,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '-${p.discountPercent.toInt()}%',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                // Back button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 8,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4)
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: AppTheme.textDark, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                // Top-right wishlist
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  right: 8,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4)
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        color: isWishlisted ? Colors.red : AppTheme.textGray,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => widget.appState.wishlist.toggle(p)),
                    ),
                  ),
                ),
              ],
            ),

            // Product info block
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          p.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          p.unit,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mã sản phẩm: ${p.id}',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textLight),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _InfoChip(
                          label: (p.category == 'rau_cu' ||
                                  p.category == 'trai_cay')
                              ? 'VietGAP'
                              : 'Tươi sạch'),
                      const SizedBox(width: 8),
                      const _StatusDot(label: 'Còn hàng', active: true),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ...List.generate(
                          5,
                          (i) => Icon(
                                i < p.rating.floor()
                                    ? Icons.star
                                    : (i < p.rating
                                        ? Icons.star_half
                                        : Icons.star_border),
                                size: 16,
                                color: const Color(0xFFFFC107),
                              )),
                      const SizedBox(width: 8),
                      Text(
                        '${p.rating} (${p.reviewCount} đánh giá)',
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.textGray),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatPrice(p.price),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      if (p.originalPrice != null) ...[
                        const SizedBox(width: 10),
                        Text(
                          _formatPrice(p.originalPrice!),
                          style: const TextStyle(
                              fontSize: 15,
                              color: AppTheme.textLight,
                              decoration: TextDecoration.lineThrough),
                        ),
                        if (p.discountPercent > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.discountRed,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '-${p.discountPercent.toInt()}%',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFCC80)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_shipping_outlined,
                            size: 14, color: Color(0xFFE65100)),
                        SizedBox(width: 6),
                        Text(
                          'Giao hàng nhanh · TP. HỒ CHÍ MINH',
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFE65100),
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            for (int i = 0; i < _quantity; i++) {
                              widget.appState.cart.add(p);
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Đã thêm $_quantity x ${p.name} vào giỏ'),
                                backgroundColor: AppTheme.primaryGreen,
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 2),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            );
                          },
                          icon: const Icon(Icons.shopping_cart_outlined,
                              size: 16),
                          label: const Text('THÊM VÀO GIỎ',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryGreen,
                            side: const BorderSide(
                                color: AppTheme.primaryGreen, width: 1.5),
                            minimumSize: const Size(0, 46),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            for (int i = 0; i < _quantity; i++) {
                              widget.appState.cart.add(p);
                            }
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 46),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('MUA NGAY',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Description
            const _SectionDivider(),
            const _SectionHeader('MÔ TẢ SẢN PHẨM'),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark)),
                  const SizedBox(height: 8),
                  Text(
                    _descExpanded
                        ? '- Xuất xứ: Việt Nam\n'
                            '- Chất lượng: Đạt chuẩn VietGAP\n'
                            '- Không thuốc trừ sâu, không chất bảo quản\n'
                            '- Giao hàng trong ngày, giữ nguyên độ tươi ngon\n\n'
                            'Đặc điểm:\n'
                            '- Sản phẩm tươi sạch, thu hoạch hàng ngày\n'
                            '- Đóng gói vệ sinh, đảm bảo an toàn thực phẩm\n'
                            '- Tăng cường hệ miễn dịch nhờ Vitamin C dồi dào\n'
                            '- Phù hợp cho mọi lứa tuổi, đặc biệt trẻ em'
                        : '- Xuất xứ: Việt Nam\n'
                            '- Chất lượng: Đạt chuẩn VietGAP\n'
                            '- Không thuốc trừ sâu, không chất bảo quản',
                    style: const TextStyle(
                        fontSize: 14, color: AppTheme.textGray, height: 1.7),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          setState(() => _descExpanded = !_descExpanded),
                      icon: Icon(
                        _descExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 16,
                        color: AppTheme.primaryGreen,
                      ),
                      label: Text(
                        _descExpanded
                            ? 'Thu gọn nội dung'
                            : 'Xem thêm nội dung',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.primaryGreen),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppTheme.primaryGreen, width: 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tags
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'VietGAP',
                  'Tươi sạch',
                  'Giao trong ngày',
                  'Không hóa chất'
                ]
                    .map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFC8E6C9)),
                          ),
                          child: Text(tag,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.w500)),
                        ))
                    .toList(),
              ),
            ),

            // Nutrition
            const _SectionDivider(),
            const _SectionHeader('THÔNG TIN DINH DƯỠNG (100g)'),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  _NutritionRow('Calo', '25 kcal'),
                  _NutritionRow('Chất xơ', '2.5g'),
                  _NutritionRow('Protein', '1.8g'),
                  _NutritionRow('Vitamin C', '30mg'),
                ],
              ),
            ),

            // Reviews
            const _SectionDivider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: ProductReviewsSection(productId: p.id),
            ),

            // Footer
            const AppFooter(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 8, color: Color(0xFFF5F5F5));
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Text(title,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
                letterSpacing: 0.5)),
      );
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 44,
          alignment: Alignment.center,
          child: Icon(icon, size: 16, color: AppTheme.primaryGreen),
        ),
      );
}

class _NutritionRow extends StatelessWidget {
  final String label;
  final String value;
  const _NutritionRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: AppTheme.textGray)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark)),
        ]),
      );
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip({required this.label});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFC8E6C9)),
        ),
        child: Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w600)),
      );
}

class _StatusDot extends StatelessWidget {
  final String label;
  final bool active;
  const _StatusDot({required this.label, required this.active});
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: active ? AppTheme.primaryGreen : AppTheme.textGray,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: active ? AppTheme.primaryGreen : AppTheme.textGray,
                  fontWeight: FontWeight.w600)),
        ],
      );
}
