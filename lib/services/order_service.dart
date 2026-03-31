import '../models/order.dart';
import '../models/cart.dart';
import '../services/session_cache.dart';
import 'api_client.dart';

class OrderResult {
  final Order order;
  final bool fromMock;
  const OrderResult(this.order, {this.fromMock = false});
}

class OrderService {
  static const _paymentLabels = ['COD', 'CARD', 'EWALLET'];

  /// Places an order via API. Falls back to local mock order on any network/server error.
  static Future<OrderResult> create({
    required List<CartItem> items,
    required double total,
    required String address,
    required int paymentMethodIndex,
  }) async {
    final paymentMethod = paymentMethodIndex < _paymentLabels.length
        ? _paymentLabels[paymentMethodIndex]
        : 'COD';

    // Read userId from session — falls back to '0' (API accepts it)
    final userJson = SessionCache.getJson(SessionCache.kUser);
    final userId =
        userJson is Map ? (userJson['accountId'] ?? 0).toString() : '0';

    final apiItems = items.map((item) {
      final productId = item.product.productId ?? 0;
      final price = item.product.price;
      final originalPrice = item.product.originalPrice ?? price;
      final discountPerItem =
          originalPrice > price ? (originalPrice - price) : 0.0;
      final subTotal = price * item.quantity;

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
      final response = await ApiClient.post('/orders', {
        'userId': userId,
        'paymentMethod': paymentMethod,
        'paymentStatus': 'PENDING',
        'items': apiItems,
      });

      final apiOrderId = _safeStr(response['orderId'],
          fallback: 'ORD${DateTime.now().millisecondsSinceEpoch}');

      final order = Order(
        id: apiOrderId,
        apiOrderId: apiOrderId,
        items: List.from(items),
        total: total,
        createdAt: DateTime.now(),
        address: address,
        status: OrderStatus.pending,
      );

      return OrderResult(order);
    } on ApiException catch (e) {
      if (e.statusCode == 401) rethrow;
      return OrderResult(_mockOrder(items, total, address), fromMock: true);
    } catch (_) {
      return OrderResult(_mockOrder(items, total, address), fromMock: true);
    }
  }

  /// Fetches a single order by its API orderId.
  /// Returns null on any failure — caller keeps showing local data.
  static Future<Order?> fetchById(String orderId, List<CartItem> items) async {
    try {
      final response = await ApiClient.get('/orders/$orderId');
      return _parseOrderResponse(response, items);
    } catch (_) {
      return null;
    }
  }

  // ── Parsers ────────────────────────────────────────────────────────────────

  static Order? _parseOrderResponse(
      Map<String, dynamic> json, List<CartItem> items) {
    try {
      final id = _safeStr(json['orderId'],
          fallback: 'ORD${DateTime.now().millisecondsSinceEpoch}');
      final statusStr = _safeStr(json['orderStatus'], fallback: 'PENDING');
      final createdAtStr = json['createdAtUtc'] as String?;

      return Order(
        id: id,
        apiOrderId: id,
        items: items,
        total: _sumItems(json['items']),
        createdAt: createdAtStr != null
            ? (DateTime.tryParse(createdAtStr) ?? DateTime.now())
            : DateTime.now(),
        address: '',
        status: _parseApiStatus(statusStr),
      );
    } catch (_) {
      return null;
    }
  }

  static double _sumItems(dynamic rawItems) {
    if (rawItems is! List) return 0;
    double total = 0;
    for (final item in rawItems) {
      if (item is Map) {
        total += _safeDouble(item['subTotal']);
      }
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

  // ── Safe helpers ───────────────────────────────────────────────────────────

  static String _safeStr(dynamic v, {String fallback = ''}) =>
      v is String ? v : fallback;

  static double _safeDouble(dynamic v, {double fallback = 0.0}) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }
}
