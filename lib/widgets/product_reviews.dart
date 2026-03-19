import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class _Review {
  final String name;
  final double rating;
  final String comment;
  final String date;
  final List<String> tags;

  const _Review({
    required this.name,
    required this.rating,
    required this.comment,
    required this.date,
    this.tags = const [],
  });
}

class ProductReviewsSection extends StatefulWidget {
  final String productId;

  const ProductReviewsSection({super.key, required this.productId});

  @override
  State<ProductReviewsSection> createState() => _ProductReviewsSectionState();
}

class _ProductReviewsSectionState extends State<ProductReviewsSection> {
  bool _showAll = false;
  int _filterRating = 0; // 0 = all

  static const List<_Review> _reviews = [
    _Review(
        name: 'Nguyễn Thị B',
        rating: 5,
        comment: 'Rau tươi xanh, ngon, giao hàng nhanh. Tôi rất hài lòng!',
        date: '12/03/2026',
        tags: ['Tươi ngon', 'Giao nhanh']),
    _Review(
        name: 'Trần Văn C',
        rating: 4,
        comment: 'Sản phẩm chất lượng tốt, đóng gói cẩn thận. Sẽ mua lại.',
        date: '10/03/2026',
        tags: ['Đóng gói đẹp']),
    _Review(
        name: 'Lê Thị D',
        rating: 5,
        comment: 'Rau sạch thật sự, mua về nấu canh rất thơm ngon. Recommend!',
        date: '08/03/2026',
        tags: ['Sạch', 'Thơm ngon']),
    _Review(
        name: 'Phạm Văn E',
        rating: 3,
        comment: 'Hàng ổn nhưng giao hơi muộn hơn dự kiến. Vẫn tươi.',
        date: '05/03/2026',
        tags: []),
    _Review(
        name: 'Hoàng Thị F',
        rating: 5,
        comment: 'Mua thường xuyên, chất lượng ổn định, giá tốt hơn siêu thị.',
        date: '01/03/2026',
        tags: ['Giá tốt', 'Chất lượng ổn']),
  ];

  List<_Review> get _filtered => _filterRating == 0
      ? _reviews
      : _reviews.where((r) => r.rating == _filterRating).toList();

  double get _avgRating =>
      _reviews.fold(0.0, (s, r) => s + r.rating) / _reviews.length;

  Map<int, int> get _ratingDist {
    final map = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in _reviews) {
      map[r.rating.toInt()] = (map[r.rating.toInt()] ?? 0) + 1;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final display = _showAll ? filtered : filtered.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header + summary
        Row(
          children: [
            const Text('Đánh giá',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: const Text('Viết đánh giá',
                  style: TextStyle(color: AppTheme.primaryGreen, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Rating summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FBF7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Big score
              Column(
                children: [
                  Text(
                    _avgRating.toStringAsFixed(1),
                    style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryGreen,
                        height: 1),
                  ),
                  Row(
                    children: List.generate(
                        5,
                        (i) => Icon(
                              i < _avgRating.floor()
                                  ? Icons.star
                                  : (i < _avgRating
                                      ? Icons.star_half
                                      : Icons.star_border),
                              size: 14,
                              color: const Color(0xFFFFC107),
                            )),
                  ),
                  const SizedBox(height: 2),
                  Text('${_reviews.length} đánh giá',
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textLight)),
                ],
              ),
              const SizedBox(width: 20),
              // Bars
              Expanded(
                child: Column(
                  children: [5, 4, 3, 2, 1].map((star) {
                    final count = _ratingDist[star] ?? 0;
                    final fraction =
                        _reviews.isEmpty ? 0.0 : count / _reviews.length;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Text('$star',
                              style: const TextStyle(
                                  fontSize: 11, color: AppTheme.textGray)),
                          const SizedBox(width: 4),
                          const Icon(Icons.star,
                              size: 10, color: Color(0xFFFFC107)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: fraction,
                                minHeight: 6,
                                backgroundColor: const Color(0xFFE0E0E0),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFFFFC107)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                              width: 20,
                              child: Text('$count',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textLight))),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Filter chips
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [0, 5, 4, 3, 2, 1].map((r) {
              final isSelected = _filterRating == r;
              return GestureDetector(
                onTap: () => setState(() => _filterRating = r),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryGreen : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryGreen
                            : const Color(0xFFE0E0E0)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    r == 0 ? 'Tất cả' : '$r ⭐',
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : AppTheme.textGray,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        // Review list
        ...display.map((r) => _ReviewCard(review: r)),
        if (filtered.length > 3)
          TextButton(
            onPressed: () => setState(() => _showAll = !_showAll),
            child: Text(
              _showAll ? 'Thu gọn' : 'Xem tất cả ${filtered.length} đánh giá',
              style: const TextStyle(color: AppTheme.primaryGreen),
            ),
          ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final _Review review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
                child: Text(
                  review.name[0],
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryGreen),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.name,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    Row(
                      children: [
                        ...List.generate(
                            5,
                            (i) => Icon(
                                  i < review.rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 12,
                                  color: const Color(0xFFFFC107),
                                )),
                        const SizedBox(width: 6),
                        Text(review.date,
                            style: const TextStyle(
                                fontSize: 11, color: AppTheme.textLight)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(review.comment,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textGray, height: 1.5)),
          if (review.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: review.tags
                  .map((t) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(t,
                            style: const TextStyle(
                                fontSize: 11, color: AppTheme.primaryGreen)),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
