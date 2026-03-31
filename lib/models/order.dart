import 'cart.dart';

enum OrderStatus { pending, confirmed, delivering, delivered, cancelled }

class Order {
  final String id; // local display ID (may equal apiOrderId)
  final String?
      apiOrderId; // "ORD-..." string returned by the API; null for mock orders
  final List<CartItem> items;
  final double total;
  final DateTime createdAt;
  OrderStatus status;
  final String address;

  Order({
    required this.id,
    this.apiOrderId,
    required this.items,
    required this.total,
    required this.createdAt,
    required this.address,
    this.status = OrderStatus.confirmed,
  });

  /// Whether this order was successfully submitted to the API.
  bool get isApiOrder => apiOrderId != null;

  String get statusLabel {
    switch (status) {
      case OrderStatus.pending:
        return 'Chờ xác nhận';
      case OrderStatus.confirmed:
        return 'Đã xác nhận';
      case OrderStatus.delivering:
        return 'Đang giao hàng';
      case OrderStatus.delivered:
        return 'Đã giao hàng';
      case OrderStatus.cancelled:
        return 'Đã huỷ';
    }
  }
}
