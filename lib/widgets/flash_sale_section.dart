import 'dart:async';
import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../models/app_state.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../screens/product_detail_screen.dart';

class FlashSaleSection extends StatefulWidget {
  final AppState appState;

  const FlashSaleSection({super.key, required this.appState});

  @override
  State<FlashSaleSection> createState() => _FlashSaleSectionState();
}

class _FlashSaleSectionState extends State<FlashSaleSection> {
  late Timer _timer;
  late Duration _remaining;

  // Sale ends at next midnight
  final DateTime _endTime =
      DateTime.now().add(const Duration(hours: 5, minutes: 23, seconds: 47));

  List<Product> get _saleProducts => AppData.categories
      .expand((c) => c.products)
      .where((p) => p.isSale)
      .take(6)
      .toList();

  @override
  void initState() {
    super.initState();
    _remaining = _endTime.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final r = _endTime.difference(DateTime.now());
      if (mounted)
        setState(() => _remaining = r.isNegative ? Duration.zero : r);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  String _formatPrice(double p) =>
      '${p.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.')}₫';

  @override
  Widget build(BuildContext context) {
    final products = _saleProducts;
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          margin: const EdgeInsets.fromLTRB(12, 16, 12, 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE53935), Color(0xFFFF6F00)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Row(
            children: [
              const Text('⚡', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Text(
                'FLASH SALE',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1),
              ),
              const SizedBox(width: 10),
              const Text('Kết thúc sau:',
                  style: TextStyle(color: Colors.white70, fontSize: 11)),
              const SizedBox(width: 6),
              _CountdownBox(_pad(_remaining.inHours)),
              const Text(':',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
              _CountdownBox(_pad(_remaining.inMinutes.remainder(60))),
              const Text(':',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
              _CountdownBox(_pad(_remaining.inSeconds.remainder(60))),
              const Spacer(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  foregroundColor: Colors.white70,
                ),
                child: const Row(
                  children: [
                    Text('Xem tất cả', style: TextStyle(fontSize: 12)),
                    Icon(Icons.chevron_right, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Products scroll
        Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)
            ],
          ),
          child: SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(10),
              itemCount: products.length,
              itemBuilder: (context, i) {
                final p = products[i];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(
                            product: p, appState: widget.appState)),
                  ),
                  child: Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFE0E0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10)),
                              child: Image.network(
                                p.imageUrl,
                                width: 120,
                                height: 110,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                    width: 120,
                                    height: 110,
                                    color: const Color(0xFFFFE0E0)),
                              ),
                            ),
                            Positioned(
                              top: 6,
                              left: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.discountRed,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '-${p.discountPercent.toInt()}%',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text(_formatPrice(p.price),
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.discountRed)),
                              if (p.originalPrice != null)
                                Text(_formatPrice(p.originalPrice!),
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: AppTheme.textLight,
                                        decoration:
                                            TextDecoration.lineThrough)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _CountdownBox extends StatelessWidget {
  final String value;
  const _CountdownBox(this.value);

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          value,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppTheme.discountRed),
        ),
      );
}
