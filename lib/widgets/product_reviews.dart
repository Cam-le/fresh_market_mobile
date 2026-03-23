import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class _Review {
  final String author;
  final double rating;
  final String comment;
  final String date;

  const _Review({
    required this.author,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

const _kReviews = [
  _Review(
    author: 'Nguyễn Thị Lan',
    rating: 5,
    comment: 'Sản phẩm chất lượng, tươi ngon, giao hàng nhanh.',
    date: '8 tháng trước',
  ),
  _Review(
    author: 'Trần Văn Minh',
    rating: 5,
    comment: 'Hàng mới, giao hàng nhanh. Sẽ mua lại.',
    date: '8 tháng trước',
  ),
  _Review(
    author: 'Phạm Thị Hoa',
    rating: 4,
    comment: 'Sản phẩm tươi, đóng gói cẩn thận. Rất hài lòng.',
    date: '6 tháng trước',
  ),
  _Review(
    author: 'Lê Quốc Tuấn',
    rating: 5,
    comment: 'Tươi sạch, đúng mô tả. Giao đúng giờ.',
    date: '5 tháng trước',
  ),
];

class ProductReviewsSection extends StatefulWidget {
  final String productId;

  const ProductReviewsSection({super.key, required this.productId});

  @override
  State<ProductReviewsSection> createState() => _ProductReviewsSectionState();
}

class _ProductReviewsSectionState extends State<ProductReviewsSection> {
  int _filterStar = 0; // 0 = all

  List<_Review> get _filtered => _filterStar == 0
      ? _kReviews
      : _kReviews.where((r) => r.rating.floor() == _filterStar).toList();

  double get _avgRating =>
      _kReviews.fold(0.0, (s, r) => s + r.rating) / _kReviews.length;

  Map<int, int> get _distribution {
    final map = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in _kReviews) {
      map[r.rating.floor()] = (map[r.rating.floor()] ?? 0) + 1;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final dist = _distribution;
    final total = _kReviews.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ĐÁNH GIÁ SẢN PHẨM',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),

        // ── Summary row ──────────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Big avg score
            Column(
              children: [
                Text(
                  _avgRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
                const Text(
                  '/ 5',
                  style: TextStyle(fontSize: 13, color: AppTheme.textGray),
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < _avgRating.floor()
                          ? Icons.star
                          : (i < _avgRating
                              ? Icons.star_half
                              : Icons.star_border),
                      size: 16,
                      color: const Color(0xFFFFC107),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Dựa trên $total đánh giá',
                  style:
                      const TextStyle(fontSize: 10, color: AppTheme.textLight),
                ),
              ],
            ),
            const SizedBox(width: 20),

            // Distribution bars
            Expanded(
              child: Column(
                children: [5, 4, 3, 2, 1].map((star) {
                  final count = dist[star] ?? 0;
                  final pct = total == 0 ? 0.0 : count / total;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            star,
                            (_) => const Icon(Icons.star,
                                size: 10, color: Color(0xFFFFC107)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 8,
                              backgroundColor: const Color(0xFFEEEEEE),
                              color: pct > 0
                                  ? const Color(0xFFFFC107)
                                  : const Color(0xFFEEEEEE),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: 44,
                          child: Text(
                            '${(pct * 100).toInt()}%($count)',
                            style: const TextStyle(
                                fontSize: 9, color: AppTheme.textLight),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Filter chips ─────────────────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _StarFilterChip(
                label: 'Tất cả',
                selected: _filterStar == 0,
                onTap: () => setState(() => _filterStar = 0),
              ),
              ...List.generate(
                5,
                (i) => _StarFilterChip(
                  label: '${5 - i} sao',
                  selected: _filterStar == 5 - i,
                  onTap: () => setState(() => _filterStar = 5 - i),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Review list ──────────────────────────────────────────────
        ..._filtered.map((r) => _ReviewCard(review: r)),

        if (_filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Không có đánh giá nào.',
                style: TextStyle(color: AppTheme.textGray),
              ),
            ),
          ),

        // ── Shop reply stub ──────────────────────────────────────────
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FRESH FOOD MARKET',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryGreen),
              ),
              SizedBox(height: 4),
              Text(
                'Cảm ơn quý khách đã tin tưởng và ủng hộ FRESH FOOD MARKET ạ.',
                style: TextStyle(fontSize: 13, color: AppTheme.textGray),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _StarFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StarFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.primaryGreen : const Color(0xFFDDDDDD),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppTheme.textGray,
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final _Review review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFE8F5E9),
            child: Text(
              review.author.isNotEmpty ? review.author[0] : '?',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryGreen),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.author,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark),
                      ),
                    ),
                    Text(
                      review.date,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textLight),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < review.rating.floor()
                          ? Icons.star
                          : Icons.star_border,
                      size: 13,
                      color: const Color(0xFFFFC107),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  review.comment,
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textGray, height: 1.5),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    '↩ Reply',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
