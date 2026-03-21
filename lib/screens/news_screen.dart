import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../models/news.dart';
import '../theme/app_theme.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String _selectedCategory = 'Tất cả';

  List<NewsArticle> get _filtered => _selectedCategory == 'Tất cả'
      ? AppData.articles
      : AppData.articles.where((a) => a.category == _selectedCategory).toList();

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 130,
            backgroundColor: AppTheme.primaryGreen,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.darkGreen,
                      AppTheme.primaryGreen.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tin Tức & Sức Khỏe',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Kiến thức dinh dưỡng, công thức & xu hướng',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            title: const Text(
              'Tin Tức',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: Container(
                height: 44,
                color: AppTheme.primaryGreen,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  itemCount: AppData.newsCategories.length,
                  itemBuilder: (context, i) {
                    final cat = AppData.newsCategories[i];
                    final selected = cat == _selectedCategory;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                selected ? AppTheme.primaryGreen : Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Featured article
          if (filtered.isNotEmpty)
            SliverToBoxAdapter(
              child: _FeaturedCard(
                article: filtered.first,
                onTap: () => _openDetail(context, filtered.first),
              ),
            ),

          // Count
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '${filtered.length} bài viết',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Rest of articles
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final article = filtered[i + 1];
                return _ArticleListTile(
                  article: article,
                  onTap: () => _openDetail(context, article),
                );
              },
              childCount: filtered.length > 1 ? filtered.length - 1 : 0,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context, NewsArticle article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewsDetailScreen(article: article),
      ),
    );
  }
}

// ── Featured card ─────────────────────────────────────────────────────────────

class _FeaturedCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onTap;

  const _FeaturedCard({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
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
                height: 200,
                width: double.infinity,
                child: Image.network(
                  article.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: const Color(0xFFE8F5E9)),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.75),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
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
                    _CategoryChip(label: article.category),
                    const SizedBox(height: 8),
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
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'Biên tập bởi ${article.author}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11),
                        ),
                        const Spacer(),
                        const Icon(Icons.remove_red_eye_outlined,
                            size: 12, color: Colors.white60),
                        const SizedBox(width: 4),
                        Text(
                          '${article.views}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── List tile ─────────────────────────────────────────────────────────────────

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
        padding: const EdgeInsets.all(12),
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
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 90,
                height: 90,
                child: Image.network(
                  article.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: const Color(0xFFE8F5E9)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CategoryChip(label: article.category, small: true),
                  const SizedBox(height: 6),
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.summary,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textGray,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 11, color: AppTheme.textLight),
                      const SizedBox(width: 3),
                      Text(article.author,
                          style: const TextStyle(
                              fontSize: 10, color: AppTheme.textLight)),
                      const SizedBox(width: 10),
                      const Icon(Icons.calendar_today_outlined,
                          size: 11, color: AppTheme.textLight),
                      const SizedBox(width: 3),
                      Text(article.date,
                          style: const TextStyle(
                              fontSize: 10, color: AppTheme.textLight)),
                      const Spacer(),
                      const Icon(Icons.remove_red_eye_outlined,
                          size: 11, color: AppTheme.textLight),
                      const SizedBox(width: 3),
                      Text('${article.views}',
                          style: const TextStyle(
                              fontSize: 10, color: AppTheme.textLight)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Category chip ─────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool small;

  const _CategoryChip({required this.label, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 7 : 10, vertical: small ? 2 : 3),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: small ? 9 : 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryGreen,
        ),
      ),
    );
  }
}

// ── Detail screen ─────────────────────────────────────────────────────────────

class NewsDetailScreen extends StatelessWidget {
  final NewsArticle article;

  const NewsDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppTheme.primaryGreen,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.35),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.35),
                  child: IconButton(
                    icon: const Icon(Icons.share_outlined,
                        color: Colors.white, size: 18),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    article.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: const Color(0xFFE8F5E9)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.4),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
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
                  _CategoryChip(label: article.category),
                  const SizedBox(height: 12),
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textDark,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 13, color: AppTheme.textLight),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Biên tập bởi ${article.author} ngày ${article.date}',
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textGray),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.share_outlined,
                          size: 13, color: AppTheme.textLight),
                      const SizedBox(width: 4),
                      Text('${article.shares}',
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textGray)),
                      const SizedBox(width: 16),
                      const Icon(Icons.remove_red_eye_outlined,
                          size: 13, color: AppTheme.textLight),
                      const SizedBox(width: 4),
                      Text('${article.views}',
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textGray)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Table of contents
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nội Dung',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...article.sections
                            .where((s) => s.heading != null)
                            .map((s) => Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('• ',
                                          style: TextStyle(
                                              color: AppTheme.primaryGreen,
                                              fontSize: 12)),
                                      Expanded(
                                        child: Text(
                                          s.heading!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.primaryGreen,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Summary
                  Text(
                    article.summary,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.textDark,
                      height: 1.65,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Body sections
                  ...article.sections.map((section) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (section.heading != null) ...[
                              Text(
                                section.heading!,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textDark,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            Text(
                              section.body,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textDark,
                                height: 1.7,
                              ),
                            ),
                          ],
                        ),
                      )),

                  const Divider(),
                  const SizedBox(height: 16),

                  // Related articles
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.accentOrange.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Có thể bạn quan tâm:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...AppData.articles
                            .where((a) => a.id != article.id)
                            .take(3)
                            .map((a) => Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('• ',
                                          style: TextStyle(
                                              color: AppTheme.accentOrange,
                                              fontSize: 12)),
                                      Expanded(
                                        child: Text(
                                          a.title,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF1565C0),
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
