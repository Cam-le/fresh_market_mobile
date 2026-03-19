import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../models/product.dart';
import '../data/app_data.dart';
import '../theme/app_theme.dart';
import '../screens/product_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  final AppState appState;

  const WishlistScreen({super.key, required this.appState});

  List<Product> get _wishlisted {
    final all = AppData.categories.expand((c) => c.products).toList();
    return all.where((p) => appState.wishlist.contains(p.id)).toList();
  }

  String _formatPrice(double price) {
    final f = price
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');
    return '$f₫';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final items = _wishlisted;

        return Scaffold(
          appBar: AppBar(
            title: Text('Yêu thích (${items.length})'),
          ),
          body: items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border,
                          size: 72, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text('Chưa có sản phẩm yêu thích',
                          style: TextStyle(
                              fontSize: 16, color: AppTheme.textGray)),
                      const SizedBox(height: 8),
                      const Text('Nhấn ♡ trên sản phẩm để lưu vào đây',
                          style: TextStyle(
                              fontSize: 13, color: AppTheme.textLight)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final p = items[i];
                    return Dismissible(
                      key: Key(p.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.discountRed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.favorite_border,
                            color: Colors.white),
                      ),
                      onDismissed: (_) => appState.wishlist.toggle(p),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(
                                product: p, appState: appState),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 6)
                            ],
                          ),
                          child: Row(
                            children: [
                              // Image
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                                child: Image.network(
                                  p.imageUrl,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 100,
                                    height: 100,
                                    color: const Color(0xFFE8F5E9),
                                    child: const Icon(Icons.image_not_supported,
                                        color: AppTheme.primaryGreen),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Info
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(p.name,
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Text(p.unit,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textLight)),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text(_formatPrice(p.price),
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800,
                                                  color:
                                                      AppTheme.primaryGreen)),
                                          if (p.originalPrice != null) ...[
                                            const SizedBox(width: 8),
                                            Text(_formatPrice(p.originalPrice!),
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppTheme.textLight,
                                                    decoration: TextDecoration
                                                        .lineThrough)),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Add to cart
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () => appState.wishlist.toggle(p),
                                      child: const Icon(Icons.favorite,
                                          color: Colors.red, size: 22),
                                    ),
                                    const SizedBox(height: 12),
                                    GestureDetector(
                                      onTap: () {
                                        appState.addToCart(p);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content:
                                              Text('Đã thêm ${p.name} vào giỏ'),
                                          backgroundColor:
                                              AppTheme.primaryGreen,
                                          behavior: SnackBarBehavior.floating,
                                          duration: const Duration(seconds: 1),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ));
                                      },
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryGreen,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                            Icons.add_shopping_cart,
                                            color: Colors.white,
                                            size: 18),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
