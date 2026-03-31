import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/cart.dart';
import '../models/product.dart';
import '../data/app_data.dart';
import '../services/session_cache.dart';
import 'api_client.dart';

class OrderResult {
  final Order order;
  final bool fromMock;
  const OrderResult(this.order, {this.fromMock = false});
}

class OrderService {
  static const _paymentLabels = ['COD', 'CARD', 'EWALLET'];

  /// POST /orders then GET /orders/{id} to get fully hydrated order.
  /// Falls back to local mock on any network/server error.
  static Future<OrderResult> create({
    required List<CartItem> items,
    required double total,
    required String address,
    required int paymentMethodIndex,
  }) async {
    final paymentMethod = paymentMethodIndex < _paymentLabels.length
        ? _paymentLabels[paymentMethodIndex]
        : 'COD';

    final userJson = SessionCache.getJson(SessionCache.kUser);
    String userId = '0';
    if (userJson is Map) {
      final raw = userJson['accountId'];
      if (raw is int && raw != 0) {
        userId = raw.toString();
      } else if (raw is String && raw.isNotEmpty && raw != '0') {
        userId = raw;
      }
    }

    final token = SessionCache.getJson(SessionCache.kAuthToken);
    debugPrint(
        '[OrderService] token=${token != null ? 'PRESENT (${token.toString().length} chars)' : 'NULL'} | userId=$userId');

    final apiItems = items.map((item) {
      final productId = item.product.productId ?? 0;
      final price = item.product.price;
      final originalPrice = item.product.originalPrice ?? price;
      final discountPerItem =
          originalPrice > price ? (originalPrice - price) : 0.0;
      final subTotal = price * item.quantity;
      debugPrint(
          '[OrderService] item: productId=$productId name=${item.product.name} qty=${item.quantity} price=$price');
      return {
        'productId': productId,
        'productName': item.product.name,
        'quantity': item.quantity,
        'discountPerItem': discountPerItem,
        'subTotal': subTotal,
        'price': price,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      };
    }).toList();

    try {
      // Step 1: POST to create order
      final postResponse = await ApiClient.post('/orders', {
        'userId': userId,
        'paymentMethod': paymentMethod,
        'paymentStatus': 'PENDING',
        'items': apiItems,
      });

      debugPrint('[OrderService] POST SUCCESS: $postResponse');

      final apiOrderId = _safeStr(postResponse['orderId'],
          fallback: 'ORD${DateTime.now().millisecondsSinceEpoch}');

      // Step 2: GET to fetch full order details
      Order order;
      try {
        final getResponse = await ApiClient.get('/orders/$apiOrderId');
        debugPrint('[OrderService] GET SUCCESS: $getResponse');
        order = _buildOrderFromGetResponse(
          json: getResponse,
          originalItems: items,
          address: address,
          fallbackTotal: total,
        );
      } catch (e) {
        // GET failed — build order from POST response + original cart items
        debugPrint('[OrderService] GET failed, using POST data: $e');
        order = Order(
          id: apiOrderId,
          apiOrderId: apiOrderId,
          items: List.from(items),
          total: total,
          createdAt: DateTime.now(),
          address: address,
          status: _parseApiStatus(
              _safeStr(postResponse['orderStatus'], fallback: 'PENDING')),
        );
      }

      return OrderResult(order);
    } on ApiException catch (e) {
      debugPrint(
          '[OrderService] API EXCEPTION: status=${e.statusCode} msg=${e.message}');
      if (e.statusCode == 401) rethrow;
      return OrderResult(_mockOrder(items, total, address), fromMock: true);
    } catch (e) {
      debugPrint('[OrderService] UNEXPECTED ERROR: $e');
      return OrderResult(_mockOrder(items, total, address), fromMock: true);
    }
  }

  /// Fetches a single order by orderId for display (e.g. order detail refresh).
  /// Returns null on failure — caller keeps showing cached data.
  static Future<Order?> fetchById(
      String orderId, List<CartItem> originalItems) async {
    try {
      final response = await ApiClient.get('/orders/$orderId');
      return _buildOrderFromGetResponse(
        json: response,
        originalItems: originalItems,
        address: '',
        fallbackTotal: _sumItems(response['items']),
      );
    } catch (_) {
      return null;
    }
  }

  // ── Builder ────────────────────────────────────────────────────────────────

  /// Builds an [Order] from GET /orders/{id} response.
  /// Uses original cart items when available; falls back to synthetic products
  /// built from the API's raw item data for items not in local AppData.
  static Order _buildOrderFromGetResponse({
    required Map<String, dynamic> json,
    required List<CartItem> originalItems,
    required String address,
    required double fallbackTotal,
  }) {
    final id = _safeStr(json['orderId'],
        fallback: 'ORD${DateTime.now().millisecondsSinceEpoch}');
    final statusStr = _safeStr(json['orderStatus'], fallback: 'PENDING');
    final createdAtStr = json['createdAtUtc'] as String?;
    final createdAt = createdAtStr != null
        ? (DateTime.tryParse(createdAtStr) ?? DateTime.now())
        : DateTime.now();

    // Build display items — prefer original CartItems, fall back to API data
    final displayItems = _resolveItems(json['items'], originalItems);
    final apiTotal = _sumItems(json['items']);

    return Order(
      id: id,
      apiOrderId: id,
      items: displayItems,
      total: apiTotal > 0 ? apiTotal : fallbackTotal,
      createdAt: createdAt,
      address: address,
      status: _parseApiStatus(statusStr),
    );
  }

  /// Maps API raw items to CartItems.
  /// For each API item, tries to find a matching product in originalItems
  /// (by productId) first, then in AppData, then synthesises a minimal Product.
  static List<CartItem> _resolveItems(
      dynamic rawItems, List<CartItem> originalItems) {
    if (rawItems is! List || rawItems.isEmpty) {
      // GET returned no items — use original cart items
      return List.from(originalItems);
    }

    final result = <CartItem>[];
    for (final raw in rawItems) {
      if (raw is! Map) continue;
      final productId = _safeInt(raw['productId']);
      final quantity = _safeInt(raw['quantity'], fallback: 1);
      final price = _safeDouble(raw['price']);
      final productName = _safeStr(raw['productName'], fallback: 'Sản phẩm');

      // 1. Match against original cart items by productId
      CartItem? match;
      if (productId != 0) {
        try {
          match = originalItems.firstWhere(
            (ci) => ci.product.productId == productId,
          );
        } catch (_) {
          match = null;
        }
      }

      if (match != null) {
        result.add(CartItem(product: match.product, quantity: quantity));
        continue;
      }

      // 2. Match against AppData by productId
      Product? appProduct;
      if (productId != 0) {
        try {
          appProduct = AppData.allProducts.firstWhere(
            (p) => p.productId == productId,
          );
        } catch (_) {
          appProduct = null;
        }
      }

      if (appProduct != null) {
        result.add(CartItem(product: appProduct, quantity: quantity));
        continue;
      }

      // 3. Synthesise a minimal Product from API data so UI never breaks
      final synthetic = Product(
        id: productId.toString(),
        productId: productId,
        name: productName,
        price: price,
        rating: 0,
        reviewCount: 0,
        imageUrl: '',
        unit: '',
        category: '',
      );
      result.add(CartItem(product: synthetic, quantity: quantity));
    }

    return result.isEmpty ? List.from(originalItems) : result;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static double _sumItems(dynamic rawItems) {
    if (rawItems is! List) return 0;
    double total = 0;
    for (final item in rawItems) {
      if (item is Map) total += _safeDouble(item['subTotal']);
    }
    return total;
  }

  static OrderStatus _parseApiStatus(String s) {
    switch (s.toUpperCase()) {
      case 'PENDING':
        return OrderStatus.pending;
      case 'CONFIRMED':
        return OrderStatus.confirmed;
      case 'DELIVERING':
      case 'SHIPPING':
        return OrderStatus.delivering;
      case 'DELIVERED':
      case 'COMPLETED':
        return OrderStatus.delivered;
      case 'CANCELLED':
      case 'CANCELED':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  static Order _mockOrder(List<CartItem> items, double total, String address) {
    return Order(
      id: 'ORD${DateTime.now().millisecondsSinceEpoch}',
      apiOrderId: null,
      items: List.from(items),
      total: total,
      createdAt: DateTime.now(),
      address: address,
      status: OrderStatus.confirmed,
    );
  }

  static String _safeStr(dynamic v, {String fallback = ''}) =>
      v is String ? v : fallback;

  static int _safeInt(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  static double _safeDouble(dynamic v, {double fallback = 0.0}) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }
}
