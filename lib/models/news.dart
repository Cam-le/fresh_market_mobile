class NewsSection {
  final String heading;
  final String body;

  const NewsSection({required this.heading, required this.body});
}

class NewsArticle {
  final int newsId;
  final int subCategoryId;
  final String id; // string alias of newsId for backward compat
  final String title;
  final String author; // not in API — defaults to category name
  final String date; // formatted from publishDate or createdDate
  final String category;
  final String imageUrl;
  final String summary; // mapped from content
  final int views; // not in API — default 0
  final int shares; // not in API — default 0
  final String status;
  final DateTime? publishDate;
  final DateTime createdDate;
  final DateTime? updatedDate;
  final List<NewsSection> sections; // built from content for detail screen

  const NewsArticle({
    required this.newsId,
    required this.subCategoryId,
    required this.id,
    required this.title,
    required this.author,
    required this.date,
    required this.category,
    required this.imageUrl,
    required this.summary,
    required this.views,
    required this.shares,
    required this.status,
    this.publishDate,
    required this.createdDate,
    this.updatedDate,
    required this.sections,
  });

  /// Safe factory from API JSON. Every field has a fallback — a malformed
  /// or partial response will never throw.
  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    final newsId = _parseInt(json['newsId']);
    final content = _parseStr(json['content']);
    final category = _parseStr(json['category'], fallback: 'Tin tức');
    final publishDate = _parseDate(json['publishDate']);
    final createdDate = _parseDate(json['createdDate']) ?? DateTime.now();
    final displayDate = _formatDate(publishDate ?? createdDate);

    // Build a single section from the content so NewsDetailScreen
    // renders it properly without needing changes.
    final sections = content.isNotEmpty
        ? [NewsSection(heading: 'Nội dung', body: content)]
        : <NewsSection>[];

    return NewsArticle(
      newsId: newsId,
      subCategoryId: _parseInt(json['subCategoryId']),
      id: newsId.toString(),
      title: _parseStr(json['title'], fallback: 'Bài viết'),
      author: category, // API has no author field — use category
      date: displayDate,
      category: category,
      imageUrl: _parseStr(json['image'],
          fallback:
              'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800'),
      summary: content.length > 120 ? '${content.substring(0, 120)}…' : content,
      views: 0,
      shares: 0,
      status: _parseStr(json['status'], fallback: 'Published'),
      publishDate: publishDate,
      createdDate: createdDate,
      updatedDate: _parseDate(json['updatedDate']),
      sections: sections,
    );
  }

  // ── Mock fallback data — used when API is unreachable ──────────────────

  static List<NewsArticle> get mockList => [
        NewsArticle(
          newsId: 1,
          subCategoryId: 1,
          id: '1',
          title: 'Top 5 loại rau xanh tốt nhất cho sức khỏe',
          author: 'Dinh dưỡng',
          date: '15/03/2026',
          category: 'Dinh dưỡng',
          imageUrl:
              'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800',
          summary:
              'Rau xanh là nguồn cung cấp vitamin và khoáng chất thiết yếu cho cơ thể mỗi ngày.',
          views: 1240,
          shares: 86,
          status: 'Published',
          publishDate: DateTime(2026, 3, 15),
          createdDate: DateTime(2026, 3, 14),
          sections: const [
            NewsSection(
              heading: 'Tại sao rau xanh quan trọng?',
              body:
                  'Rau xanh cung cấp chất xơ, vitamin C, K và nhiều khoáng chất cần thiết giúp tăng cường hệ miễn dịch.',
            ),
            NewsSection(
              heading: 'Các loại rau nên ăn hàng ngày',
              body:
                  'Cải xanh, bông cải xanh, rau chân vịt, cải kale và rau muống là những lựa chọn hàng đầu.',
            ),
          ],
        ),
        NewsArticle(
          newsId: 2,
          subCategoryId: 2,
          id: '2',
          title: 'Trái cây theo mùa — ăn gì tháng 3?',
          author: 'Thực phẩm',
          date: '10/03/2026',
          category: 'Thực phẩm',
          imageUrl:
              'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=800',
          summary:
              'Tháng 3 là mùa của nhiều loại trái cây ngon, bổ dưỡng và giá thành hợp lý.',
          views: 980,
          shares: 54,
          status: 'Published',
          publishDate: DateTime(2026, 3, 10),
          createdDate: DateTime(2026, 3, 9),
          sections: const [
            NewsSection(
              heading: 'Trái cây mùa xuân',
              body:
                  'Xoài, thanh long, dưa hấu bắt đầu vào mùa với giá tốt và chất lượng cao.',
            ),
          ],
        ),
        NewsArticle(
          newsId: 3,
          subCategoryId: 3,
          id: '3',
          title: 'Hải sản tươi sống — cách chọn mua đúng cách',
          author: 'Mẹo hay',
          date: '05/03/2026',
          category: 'Mẹo hay',
          imageUrl:
              'https://images.unsplash.com/photo-1559737558-2f5a35f4523b?w=800',
          summary:
              'Chọn hải sản tươi không khó nếu bạn biết những dấu hiệu nhận biết cơ bản.',
          views: 756,
          shares: 42,
          status: 'Published',
          publishDate: DateTime(2026, 3, 5),
          createdDate: DateTime(2026, 3, 4),
          sections: const [
            NewsSection(
              heading: 'Dấu hiệu hải sản còn tươi',
              body:
                  'Mắt trong, mang đỏ, thịt đàn hồi và không có mùi hôi là những tiêu chí quan trọng.',
            ),
          ],
        ),
      ];

  // ── Helpers ────────────────────────────────────────────────────────────

  static int _parseInt(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  static String _parseStr(dynamic v, {String fallback = ''}) {
    if (v is String) return v;
    return fallback;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }

  static String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }
}
