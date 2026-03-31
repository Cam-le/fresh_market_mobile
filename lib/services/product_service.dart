import '../data/app_data.dart';
import '../models/product.dart';
import 'api_client.dart';

class ProductService {
  // Maps API categoryName strings → our internal ProductCategory ids
  static const _categoryIdMap = {
    'Rau, Củ & Nấm': 'rau_cu',
    'Trái Cây': 'trai_cay',
    'Thịt, Cá & Hải Sản': 'thit',
    'Thực Phẩm Khô': 'thuc_pham_kho',
  };

  // Display names for category ids
  static const _categoryNameMap = {
    'rau_cu': 'Rau Củ & Nấm',
    'trai_cay': 'Trái Cây Tươi Ngon',
    'thit': 'Thịt, Cá & Hải Sản',
    'hai_san': 'Hải Sản & Thủy Sản',
    'thuc_pham_kho': 'Thực Phẩm Khô',
  };

  // Category order for display
  static const _categoryOrder = [
    'rau_cu',
    'trai_cay',
    'thit',
    'hai_san',
    'thuc_pham_kho',
  ];

  /// Fetches all products from the API and writes them into [AppData] cache.
  /// On any failure, [AppData] keeps serving mock data — no error propagates.
  static Future<void> fetchAll() async {
    try {
      final response = await ApiClient.get('/product');

      if (response['success'] != true) return;

      final rawList = response['data'];
      if (rawList == null || rawList is! List) return;

      final products = <Product>[];

      for (final item in rawList) {
        if (item is! Map<String, dynamic>) continue;
        try {
          final categoryId = _resolveCategoryId(item);
          final product = Product.fromJson(item, categoryId);
          products.add(product);
        } catch (_) {
          // Skip malformed individual product — don't abort the whole list
          continue;
        }
      }

      if (products.isEmpty) return; // Don't wipe mock with empty list

      final categories = _buildCategories(products);
      AppData.setLiveData(products: products, categories: categories);
    } catch (_) {
      // Network error or unexpected shape — silently keep mock data
    }
  }

  /// Fetches a single product by its API productId.
  /// Returns null on any failure — caller falls back to the cached product.
  static Future<Product?> fetchById(int productId) async {
    try {
      final response = await ApiClient.get('/product/$productId');
      if (response['success'] != true) return null;

      final data = response['data'];
      if (data is! Map<String, dynamic>) return null;

      final categoryId = _resolveCategoryId(data);
      return Product.fromJson(data, categoryId);
    } catch (_) {
      return null;
    }
  }

  // ── Internals ──────────────────────────────────────────────────────────────

  /// Resolves the API's categoryName to our internal category id.
  /// Falls back to 'rau_cu' so the product still appears somewhere.
  static String _resolveCategoryId(Map<String, dynamic> json) {
    final apiCategoryName = json['categoryName'] as String? ?? '';
    return _categoryIdMap[apiCategoryName] ?? 'rau_cu';
  }

  /// Groups products by category and returns ordered [ProductCategory] list.
  static List<ProductCategory> _buildCategories(List<Product> products) {
    final grouped = <String, List<Product>>{};
    for (final p in products) {
      grouped.putIfAbsent(p.category, () => []).add(p);
    }

    final result = <ProductCategory>[];

    // Add in preferred display order first
    for (final catId in _categoryOrder) {
      final catProducts = grouped[catId];
      if (catProducts != null && catProducts.isNotEmpty) {
        result.add(ProductCategory(
          id: catId,
          name: _categoryNameMap[catId] ?? catId,
          products: catProducts,
        ));
      }
    }

    // Add any unexpected categories from the API that aren't in our order list
    for (final entry in grouped.entries) {
      if (!_categoryOrder.contains(entry.key) && entry.value.isNotEmpty) {
        result.add(ProductCategory(
          id: entry.key,
          name: _categoryNameMap[entry.key] ?? entry.key,
          products: entry.value,
        ));
      }
    }

    return result;
  }
}
