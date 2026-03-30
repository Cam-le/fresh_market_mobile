import 'package:flutter/material.dart';
import '../models/news.dart';
import '../services/blog_service.dart';
import '../theme/app_theme.dart';
import 'news_detail_screen.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String _selectedCategory = 'Tất cả';
  List<NewsArticle> _articles = [];
  bool _isLoading = true;
  bool _fromMock = false;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    setState(() => _isLoading = true);

    final result = await BlogService.getAll();
    final isMock = result.isNotEmpty &&
        result.every(
            (a) => NewsArticle.mockList.any((m) => m.newsId == a.newsId));

    if (!mounted) return;
    setState(() {
      _articles = result;
      _fromMock = isMock;
      _isLoading = false;
    });
  }

  List<String> get _categories {
    final cats = _articles.map((a) => a.category).toSet().toList();
    cats.sort();
    return ['Tất cả', ...cats];
  }

  List<NewsArticle> get _filtered {
    if (_selectedCategory == 'Tất cả') return _articles;
    return _articles.where((a) => a.category == _selectedCategory).toList();
  }

  void _openArticle(NewsArticle article) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NewsDetailScreen(article: article)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          if (_isLoading)
            const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()))
          else if (_articles.isEmpty)
            SliverFillRemaining(child: _buildEmpty())
          else
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_fromMock) _buildMockBanner(),
                  _buildCategoryTabs(),
                  _buildContent(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppTheme.primaryGreen,
      automaticallyImplyLeading: false,
      title: const Text(
        'Tin Tức & Sức Khỏe',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tìm kiếm bài viết — sắp ra mắt'),
              behavior: SnackBarBehavior.floating,
            ),
          ),
          icon: const Icon(Icons.search, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildMockBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppTheme.accentOrange.withValues(alpha: 0.12),
      child: const Row(
        children: [
          Icon(Icons.wifi_off, size: 14, color: AppTheme.accentOrange),
          SizedBox(width: 6),
          Text(
            'Đang hiển thị dữ liệu demo — không kết nối được máy chủ',
            style: TextStyle(fontSize: 11, color: AppTheme.accentOrange),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.article_outlined,
              size: 56, color: AppTheme.textLight),
          const SizedBox(height: 12),
          const Text(
            'Không có bài viết',
            style: TextStyle(fontSize: 15, color: AppTheme.textGray),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadArticles,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Tải lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final cats = _categories;
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: cats.length,
        itemBuilder: (context, i) {
          final cat = cats[i];
          final selected = cat == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? AppTheme.primaryGreen : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? AppTheme.primaryGreen
                      : const Color(0xFFE0E0E0),
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [],
              ),
              child: Text(
                cat,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppTheme.textGray,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    final articles = _filtered;
    if (articles.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Text(
            'Không có bài viết trong danh mục này',
            style: TextStyle(color: AppTheme.textGray),
          ),
        ),
      );
    }
    final featured = articles.first;
    final rest = articles.length > 1 ? articles.sublist(1) : <NewsArticle>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFeaturedCard(featured),
        if (rest.isNotEmpty) _buildListSection(rest),
      ],
    );
  }

  Widget _buildFeaturedCard(NewsArticle article) {
    return GestureDetector(
      onTap: () => _openArticle(article),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              SizedBox(
                height: 220,
                width: double.infinity,
                child: Image.network(
                  article.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: AppTheme.primaryGreen),
                ),
              ),
              Container(
                height: 220,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.72),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CategoryBadge(label: article.category),
                    const SizedBox(height: 6),
                    Text(
                      article.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 11, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          article.date,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentOrange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '⭐ Nổi bật',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListSection(List<NewsArticle> articles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Text(
            'Bài viết mới nhất',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
        ),
        ...articles.map((a) => _ArticleListTile(
              article: a,
              onTap: () => _openArticle(a),
            )),
      ],
    );
  }
}

// ── Reusable sub-widgets ──────────────────────────────────────────────────────

class _CategoryBadge extends StatelessWidget {
  final String label;
  const _CategoryBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ArticleListTile extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onTap;

  const _ArticleListTile({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
              child: SizedBox(
                width: 110,
                height: 110,
                child: Image.network(
                  article.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFE8F5E9),
                    child: const Icon(Icons.image_not_supported_outlined,
                        color: AppTheme.primaryGreen),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CategoryBadge(label: article.category),
                    const SizedBox(height: 6),
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 11, color: AppTheme.textLight),
                        const SizedBox(width: 3),
                        Text(
                          article.date,
                          style: const TextStyle(
                              fontSize: 10, color: AppTheme.textLight),
                        ),
                      ],
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
