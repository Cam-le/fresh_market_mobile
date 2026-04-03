import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/cart.dart';
import '../models/product.dart';
import '../data/app_data.dart';
import 'api_client.dart';

class OrderResult {
  final Order order;
  final bool fromMock;
  const OrderResult(this.order, {this.fromMock = false});
}

class OrderService {
  static const _paymentLabels = ['COD', 'VNPAY'];

  // ── Create ─────────────────────────────────────────────────────────────────

  /// POST /order  →  builds an [Order] from the response + original cart items.
  /// Throws [ApiException] on failure — caller is responsible for showing error.
  static Future<OrderResult> create({
    required List<CartItem> items,
    required double total,
    required String shippingName,
    required String shippingPhone,
    required String shippingAddress,
    required double shippingFee,
    required int paymentMethodIndex,
    List<int> voucherIds = const [],
  }) async {
    final paymentMethod = paymentMethodIndex < _paymentLabels.length
        ? _paymentLabels[paymentMethodIndex]
        : 'COD';

    final apiItems = items.map((item) {
      final productId = item.product.productId ?? 0;
      final price = item.product.price;
      final originalPrice = item.product.originalPrice ?? price;
      final discount =
          originalPrice > price ? (originalPrice - price) * item.quantity : 0.0;
      debugPrint(
          '[OrderService] item: productId=$productId name=${item.product.name}'
          ' qty=${item.quantity} price=$price');
      return {
        'productId': productId,
        'quantity': item.quantity,
        'discount': discount,
      };
    }).toList();

    final postResponse = await ApiClient.post('/order', {
      'voucherIds': voucherIds,
      'shippingName': shippingName,
      'shippingPhone': shippingPhone,
      'shippingAddress': shippingAddress,
      'shippingFee': shippingFee,
      'paymentMethod': paymentMethod,
      'items': apiItems,
    });

    debugPrint('[OrderService] POST /order SUCCESS: $postResponse');

    // The API wraps its payload in a "data" key.
    final data = postResponse['data'];
    final responseMap = data is Map<String, dynamic> ? data : postResponse;

    final apiOrderId = _safeInt(responseMap['orderId']);
    final displayId = apiOrderId != 0
        ? apiOrderId.toString()
        : 'ORD${DateTime.now().millisecondsSinceEpoch}';

    final statusStr = _safeStr(responseMap['orderStatus'], fallback: 'PENDING');
    final createdAtStr = responseMap['createdAtUtc'] as String?;
    final createdAt = createdAtStr != null
        ? (DateTime.tryParse(createdAtStr) ?? DateTime.now())
        : DateTime.now();

    final fullAddress = '$shippingName • $shippingPhone • $shippingAddress';

    final order = Order(
      id: displayId,
      apiOrderId: apiOrderId != 0 ? apiOrderId : null,
      items: List.from(items),
      total: total,
      createdAt: createdAt,
      address: fullAddress,
      status: _parseApiStatus(statusStr),
      paymentMethod: paymentMethod,
    );

    return OrderResult(order);
  }

  // ── Fetch my orders ────────────────────────────────────────────────────────

  /// GET /order/me  →  returns the list of orders for the current user.
  /// Returns empty list on failure so the UI stays functional.
  static Future<List<Order>> fetchMyOrders() async {
    try {
      final response = await ApiClient.get('/order/me');
      final data = response['data'];
      if (data is! List) return [];

      final result = <Order>[];
      for (final raw in data) {
        if (raw is! Map<String, dynamic>) continue;
        final order = _buildOrderFromRaw(raw, []);
        if (order != null) result.add(order);
      }
      return result;
    } catch (e) {
      debugPrint('[OrderService] fetchMyOrders error: $e');
      return [];
    }
  }

  // ── Cancel ─────────────────────────────────────────────────────────────────

  /// DELETE /order  →  cancels an order by its numeric API id.
  /// Returns true on success, false on failure.
  static Future<bool> cancel(int orderId,
      {String cancelReason = 'Khách hàng huỷ'}) async {
    try {
      await ApiClient.delete('/order', {
        'orderId': orderId,
        'cancelReason': cancelReason,
      });
      return true;
    } catch (e) {
      debugPrint('[OrderService] cancel error: $e');
      return false;
    }
  }

  // ── Builder ────────────────────────────────────────────────────────────────

  static Order? _buildOrderFromRaw(
      Map<String, dynamic> json, List<CartItem> originalItems) {
    final apiOrderId = _safeInt(json['orderId']);
    if (apiOrderId == 0) return null;

    final displayId = apiOrderId.toString();
    final statusStr = _safeStr(json['orderStatus'], fallback: 'PENDING');
    final createdAtStr = json['createdAtUtc'] as String?;
    final createdAt = createdAtStr != null
        ? (DateTime.tryParse(createdAtStr) ?? DateTime.now())
        : DateTime.now();

    final address = [
      _safeStr(json['shippingName']),
      _safeStr(json['shippingPhone']),
      _safeStr(json['shippingAddress']),
    ].where((s) => s.isNotEmpty).join(' • ');

    final displayItems = _resolveItems(json['items'], originalItems);
    final total =
        _safeDouble(json['totalAmount'], fallback: _sumItems(json['items']));

    return Order(
      id: displayId,
      apiOrderId: apiOrderId,
      items: displayItems,
      total: total,
      createdAt: createdAt,
      address: address,
      status: _parseApiStatus(statusStr),
      paymentMethod: _safeStr(json['paymentMethod'], fallback: 'COD'),
    );
  }

  static List<CartItem> _resolveItems(
      dynamic rawItems, List<CartItem> originalItems) {
    if (rawItems is! List || rawItems.isEmpty) {
      return List.from(originalItems);
    }

    final result = <CartItem>[];
    for (final raw in rawItems) {
      if (raw is! Map) continue;
      final productId = _safeInt(raw['productId']);
      final quantity = _safeInt(raw['quantity'], fallback: 1);
      final price = _safeDouble(raw['price']);
      final productName = _safeStr(raw['productName'], fallback: 'Sản phẩm');

      // 1. Match original cart items by productId
      CartItem? match;
      if (productId != 0) {
        try {
          match = originalItems
              .firstWhere((ci) => ci.product.productId == productId);
        } catch (_) {
          match = null;
        }
      }
      if (match != null) {
        result.add(CartItem(product: match.product, quantity: quantity));
        continue;
      }

      // 2. Match AppData by productId
      Product? appProduct;
      if (productId != 0) {
        try {
          appProduct =
              AppData.allProducts.firstWhere((p) => p.productId == productId);
        } catch (_) {
          appProduct = null;
        }
      }
      if (appProduct != null) {
        result.add(CartItem(product: appProduct, quantity: quantity));
        continue;
      }

      // 3. Synthesise minimal Product so UI never breaks
      result.add(CartItem(
        product: Product(
          id: productId.toString(),
          productId: productId,
          name: productName,
          price: price,
          rating: 0,
          reviewCount: 0,
          imageUrl: '',
          unit: '',
          category: '',
        ),
        quantity: quantity,
      ));
    }

    return result.isEmpty ? List.from(originalItems) : result;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static double _sumItems(dynamic rawItems) {
    if (rawItems is! List) return 0;
    double total = 0;
    for (final item in rawItems) {
      if (item is Map) {
        final sub = _safeDouble(item['subTotal']);
        if (sub > 0) {
          total += sub;
        } else {
          total += _safeDouble(item['price']) *
              _safeInt(item['quantity'], fallback: 1);
        }
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
