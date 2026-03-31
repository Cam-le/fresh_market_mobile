import '../models/news.dart';
import 'api_client.dart';

class BlogService {
  /// Fetch all published articles. Falls back to mock list on any network
  /// or parse error so the News tab always has content to display.
  static Future<List<NewsArticle>> getAll() async {
    try {
      final response = await ApiClient.getPublic('/news/GUEST');

      if (response['success'] != true) return NewsArticle.mockList;

      final raw = response['data'];
      if (raw is! List) return NewsArticle.mockList;

      final articles = <NewsArticle>[];
      for (final item in raw) {
        if (item is Map<String, dynamic>) {
          try {
            final article = NewsArticle.fromJson(item);
            // Only show published articles
            if (article.status == 'Published') articles.add(article);
          } catch (_) {
            // Skip malformed individual items, don't fail the whole list
          }
        }
      }

      return articles.isNotEmpty ? articles : NewsArticle.mockList;
    } on ApiException catch (e) {
      // Real API error (non-network) — still fall back to mock for demo
      if (e.statusCode >= 500) return NewsArticle.mockList;
      return NewsArticle.mockList;
    } catch (_) {
      return NewsArticle.mockList;
    }
  }

  /// Fetch a single article by ID. Falls back to the matching mock article
  /// (or first mock) if the call fails.
  static Future<NewsArticle> getById(int newsId) async {
    try {
      final response = await ApiClient.getPublic('/news/$newsId');

      if (response['success'] != true) return _mockFallback(newsId);

      final data = response['data'];
      if (data is! Map<String, dynamic>) return _mockFallback(newsId);

      return NewsArticle.fromJson(data);
    } catch (_) {
      return _mockFallback(newsId);
    }
  }

  static NewsArticle _mockFallback(int newsId) {
    return NewsArticle.mockList.firstWhere(
      (a) => a.newsId == newsId,
      orElse: () => NewsArticle.mockList.first,
    );
  }
}
