class Product {
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
  final String category;

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
  });

  double get discountPercent {
    if (originalPrice == null || originalPrice == 0) return 0;
    return ((originalPrice! - price) / originalPrice! * 100).roundToDouble();
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
