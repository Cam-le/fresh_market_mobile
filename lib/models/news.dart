class NewsSection {
  final String? heading;
  final String body;

  const NewsSection({this.heading, required this.body});
}

class NewsArticle {
  final String id;
  final String title;
  final String author;
  final String date;
  final String category;
  final String imageUrl;
  final String summary;
  final List<NewsSection> sections;
  final int views;
  final int shares;

  const NewsArticle({
    required this.id,
    required this.title,
    required this.author,
    required this.date,
    required this.category,
    required this.imageUrl,
    required this.summary,
    required this.sections,
    this.views = 0,
    this.shares = 0,
  });
}
