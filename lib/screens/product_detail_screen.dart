import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/product_reviews.dart';

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

  String _formatPrice(double price) {
    final formatted = price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+$)'),
          (m) => '${m[1]}.',
        );
    return '$formatted₫';
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final isWishlisted = widget.appState.wishlist.contains(p.id);
    final cartQty = widget.appState.cart.quantityOf(p.id);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.primaryGreen,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: AppTheme.textDark, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: IconButton(
                  icon: Icon(
                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                    color: isWishlisted ? Colors.red : AppTheme.textGray,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() => widget.appState.wishlist.toggle(p));
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    p.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFE8F5E9),
                      child: const Icon(Icons.image_not_supported,
                          size: 60, color: AppTheme.primaryGreen),
                    ),
                  ),
                  if (p.isSale && p.discountPercent > 0)
                    Positioned(
                      top: 100,
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
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + unit
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
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Rating
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
                                size: 18,
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
                  const SizedBox(height: 16),
                  // Price
                  Row(
                    children: [
                      Text(
                        _formatPrice(p.price),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      if (p.originalPrice != null) ...[
                        const SizedBox(width: 12),
                        Text(
                          _formatPrice(p.originalPrice!),
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.textLight,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Description
                  const Text(
                    'Mô tả sản phẩm',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sản phẩm tươi sạch, được thu hoạch hàng ngày từ các vườn rau đạt chuẩn VietGAP. '
                    'Không thuốc trừ sâu, không chất bảo quản, đảm bảo an toàn cho sức khỏe cả gia đình bạn. '
                    'Giao hàng trong ngày, giữ nguyên độ tươi ngon.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textGray,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Tags
                  Wrap(
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
                                border:
                                    Border.all(color: const Color(0xFFC8E6C9)),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Nutrition facts
                  const Text(
                    'Thông tin dinh dưỡng (100g)',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 12),
                  const _NutritionRow('Calo', '25 kcal'),
                  const _NutritionRow('Chất xơ', '2.5g'),
                  const _NutritionRow('Protein', '1.8g'),
                  const _NutritionRow('Vitamin C', '30mg'),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  ProductReviewsSection(productId: p.id),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
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
        child: Row(
          children: [
            // Quantity selector
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  _QtyButton(
                    icon: Icons.remove,
                    onTap: () {
                      if (_quantity > 1) setState(() => _quantity--);
                    },
                  ),
                  Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Text(
                      '$_quantity',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                  _QtyButton(
                    icon: Icons.add,
                    onTap: () => setState(() => _quantity++),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
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
                  minimumSize: const Size(0, 52),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      cartQty > 0 ? 'Thêm vào giỏ ($cartQty)' : 'Thêm vào giỏ',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 48,
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: AppTheme.primaryGreen),
      ),
    );
  }
}

class _NutritionRow extends StatelessWidget {
  final String label;
  final String value;

  const _NutritionRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: AppTheme.textGray)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark)),
        ],
      ),
    );
  }
}
