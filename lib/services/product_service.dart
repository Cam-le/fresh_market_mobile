import 'package:flutter/foundation.dart';
import '../data/app_data.dart';
import '../models/product.dart';
import 'api_client.dart';

class ProductService {
  static const _categoryIdMap = {
    'Rau, Củ & Nấm': 'rau_cu',
    'Trái Cây': 'trai_cay',
    'Thịt, Cá & Hải Sản': 'thit',
    'Thực Phẩm Khô': 'thuc_pham_kho',
  };

  static const _categoryNameMap = {
    'rau_cu': 'Rau Củ & Nấm',
    'trai_cay': 'Trái Cây Tươi Ngon',
    'thit': 'Thịt, Cá & Hải Sản',
    'hai_san': 'Hải Sản & Thủy Sản',
    'thuc_pham_kho': 'Thực Phẩm Khô',
  };

  static const _categoryOrder = [
    'rau_cu',
    'trai_cay',
    'thit',
    'hai_san',
    'thuc_pham_kho',
  ];

  /// Fetches products AND subcategories in parallel.
  /// On any failure both caches keep serving mock/empty data.
  static Future<void> fetchAll() async {
    await Future.wait([
      _fetchProducts(),
      _fetchSubCategories(),
    ]);
  }

  static Future<void> _fetchProducts() async {
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
          products.add(Product.fromJson(item, categoryId));
        } catch (_) {
          continue;
        }
      }

      if (products.isEmpty) return;
      AppData.setLiveData(
        products: products,
        categories: _buildCategories(products),
      );
    } on ApiException catch (e) {
      debugPrint(
          '[ProductService] _fetchProducts ApiException: ${e.statusCode} ${e.message}');
    } catch (e) {
      debugPrint('[ProductService] _fetchProducts error: $e');
    }
  }

  static Future<void> _fetchSubCategories() async {
    try {
      final response = await ApiClient.get('/sub-category');
      if (response['success'] != true) return;

      final rawList = response['data'];
      if (rawList == null || rawList is! List) return;

      final subCategories = <SubCategory>[];
      for (final item in rawList) {
        if (item is! Map<String, dynamic>) continue;
        try {
          subCategories.add(SubCategory.fromJson(item));
        } catch (_) {
          continue;
        }
      }

      if (subCategories.isNotEmpty) {
        AppData.setSubCategories(subCategories);
      }
    } on ApiException catch (e) {
      debugPrint(
          '[ProductService] _fetchSubCategories ApiException: ${e.statusCode} ${e.message}');
    } catch (e) {
      debugPrint('[ProductService] _fetchSubCategories error: $e');
    }
  }

  static Future<Product?> fetchById(int productId) async {
    try {
      final response = await ApiClient.get('/product/$productId');
      if (response['success'] != true) return null;
      final data = response['data'];
      if (data is! Map<String, dynamic>) return null;
      return Product.fromJson(data, _resolveCategoryId(data));
    } on ApiException catch (e) {
      debugPrint(
          '[ProductService] fetchById($productId) ApiException: ${e.statusCode} ${e.message}');
      return null;
    } catch (e) {
      debugPrint('[ProductService] fetchById($productId) error: $e');
      return null;
    }
  }

  static String _resolveCategoryId(Map<String, dynamic> json) {
    final name = json['categoryName'] as String? ?? '';
    return _categoryIdMap[name] ?? 'rau_cu';
  }

  static List<ProductCategory> _buildCategories(List<Product> products) {
    final grouped = <String, List<Product>>{};
    for (final p in products) {
      grouped.putIfAbsent(p.category, () => []).add(p);
    }

    final result = <ProductCategory>[];
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
