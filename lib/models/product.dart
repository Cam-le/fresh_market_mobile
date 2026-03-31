class Product {
  // ── Original fields (unchanged — all existing screens keep working) ────────
  final String id;
  final String name;
  final double price;
  final double? originalPrice;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final String unit;
  final bool isNew;
  final bool isSale;
  final String category; // maps to ProductCategory.id

  // ── API fields (nullable — mock products leave these null) ─────────────────
  final int? productId;
  final int? subCategoryId;
  final String? subCategoryName;
  final String? categoryName;
  final String? description;
  final String? manufacturingLocation;
  final bool isOrganic;
  final bool isAvailable;
  final int? soldCount;
  final int? stockQuantity;
  final double? weight;
  final List<String> imageUrls; // all images from imagesJson

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.unit,
    this.isNew = false,
    this.isSale = false,
    required this.category,
    // API fields
    this.productId,
    this.subCategoryId,
    this.subCategoryName,
    this.categoryName,
    this.description,
    this.manufacturingLocation,
    this.isOrganic = false,
    this.isAvailable = true,
    this.soldCount,
    this.stockQuantity,
    this.weight,
    this.imageUrls = const [],
  });

  double get discountPercent {
    if (originalPrice == null || originalPrice == 0) return 0;
    return ((originalPrice! - price) / originalPrice! * 100).roundToDouble();
  }

  /// Builds a [Product] from the API JSON response.
  /// Every field has a safe fallback — a malformed response never throws.
  factory Product.fromJson(Map<String, dynamic> json, String categoryId) {
    final id = _parseInt(json['productId']).toString();
    final name = _parseStr(json['productName']);
    final price = _parseDouble(json['priceSell']);
    final unit = _parseStr(json['unit'], fallback: 'kg');
    final rating = _parseDouble(json['ratingAverage'], fallback: 0.0);
    final reviewCount = _parseInt(json['ratingCount']);
    final soldCount =
        json['soldCount'] != null ? _parseInt(json['soldCount']) : null;

    // Extract image URLs from imagesJson array; primary image goes first
    final imageUrls = _parseImageUrls(json['imagesJson']);
    // Filter out blob:// URLs (admin upload artifacts) — not usable on device
    final validUrls = imageUrls.where((u) => !u.startsWith('blob:')).toList();
    final primaryImage = validUrls.isNotEmpty ? validUrls.first : '';

    return Product(
      id: id,
      name: name,
      price: price,
      rating: rating,
      reviewCount: reviewCount,
      imageUrl: primaryImage,
      imageUrls: validUrls,
      unit: unit,
      category: categoryId,
      isOrganic: json['isOrganic'] == true,
      isAvailable: json['isAvailable'] != false, // default true if null
      soldCount: soldCount,
      stockQuantity:
          json['quantity'] != null ? _parseInt(json['quantity']) : null,
      weight: json['weight'] != null ? _parseDouble(json['weight']) : null,
      productId: _parseInt(json['productId']),
      subCategoryId: json['subCategoryId'] != null
          ? _parseInt(json['subCategoryId'])
          : null,
      subCategoryName: json['subCategoryName'] as String?,
      categoryName: json['categoryName'] as String?,
      description: json['description'] as String?,
      manufacturingLocation: json['manufacturingLocation'] as String?,
    );
  }

  // ── Safe parse helpers ─────────────────────────────────────────────────────

  static int _parseInt(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  static double _parseDouble(dynamic v, {double fallback = 0.0}) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  static String _parseStr(dynamic v, {String fallback = ''}) {
    if (v is String) return v;
    return fallback;
  }

  static List<String> _parseImageUrls(dynamic imagesJson) {
    if (imagesJson == null) return [];
    if (imagesJson is! List) return [];
    final urls = <String>[];
    String? primaryUrl;
    for (final item in imagesJson) {
      if (item is! Map) continue;
      final url = item['url'];
      if (url is! String || url.isEmpty) continue;
      if (item['primary'] == true) {
        primaryUrl = url;
      } else {
        urls.add(url);
      }
    }
    // Insert primary first
    if (primaryUrl != null) urls.insert(0, primaryUrl);
    return urls;
  }
}

class ProductCategory {
  final String id;
  final String name;
  final List<Product> products;

  const ProductCategory({
    required this.id,
    required this.name,
    required this.products,
  });
}
