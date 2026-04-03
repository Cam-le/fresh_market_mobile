import 'package:flutter/foundation.dart';
import 'cart.dart';
import 'wishlist.dart';
import 'order.dart';
import 'product.dart';
import 'user.dart';
import '../data/app_data.dart';
import '../services/session_cache.dart';
import '../services/order_service.dart';

class AppState extends ChangeNotifier {
  final CartModel cart = CartModel();
  final WishlistModel wishlist = WishlistModel();
  final List<Order> orders = [];

  UserModel user = UserModel(
    name: 'Nguyễn Văn A',
    email: 'user@example.com',
    phone: '0901 234 567',
    city: 'TP. Hồ Chí Minh',
  );

  int loyaltyPoints = 1250;
  bool _loaded = false;

  AppState() {
    cart.addListener(_onCartChanged);
    wishlist.addListener(_onWishlistChanged);
  }

  // ── Persistence ──────────────────────────────────────────────────────────

  Future<void> loadFromCache() async {
    if (_loaded) return;
    _loaded = true;

    final userJson = SessionCache.getJson(SessionCache.kUser);
    if (userJson is Map) {
      user = UserModel(
        accountId: userJson['accountId'] as int? ?? 0,
        username: userJson['username'] as String? ?? '',
        name: userJson['name'] as String? ?? user.name,
        email: userJson['email'] as String? ?? user.email,
        phone: userJson['phone'] as String? ?? user.phone,
        city: userJson['city'] as String? ?? user.city,
        avatarUrl: userJson['avatarUrl'] as String?,
        role: userJson['role'] as int? ?? 2,
      );
    }

    final pts = SessionCache.getJson(SessionCache.kLoyaltyPoints);
    if (pts is int) loyaltyPoints = pts;

    final wishJson = SessionCache.getJson(SessionCache.kWishlist);
    if (wishJson is List) {
      for (final id in wishJson) {
        final product = _findProduct(id as String);
        if (product != null) wishlist.forceAdd(product);
      }
    }

    final cartJson = SessionCache.getJson(SessionCache.kCart);
    if (cartJson is List) {
      for (final item in cartJson) {
        final product = _findProduct(item['id'] as String);
        if (product != null) {
          cart.forceSet(product, item['qty'] as int? ?? 1);
        }
      }
    }

    final ordersJson = SessionCache.getJson(SessionCache.kOrders);
    if (ordersJson is List) {
      for (final o in ordersJson) {
        final items = <CartItem>[];
        for (final i in (o['items'] as List? ?? [])) {
          final product = _findProduct(i['id'] as String);
          if (product != null) {
            items.add(
                CartItem(product: product, quantity: i['qty'] as int? ?? 1));
          }
        }
        if (items.isNotEmpty) {
          orders.add(Order(
            id: o['id'] as String,
            apiOrderId: o['apiOrderId'] as int?,
            items: items,
            total: (o['total'] as num).toDouble(),
            createdAt:
                DateTime.fromMillisecondsSinceEpoch(o['createdAt'] as int),
            address: o['address'] as String,
            status: _parseStatus(o['status'] as String? ?? ''),
            paymentMethod: o['paymentMethod'] as String? ?? 'COD',
          ));
        }
      }
    }

    notifyListeners();
  }

  Future<void> _saveCart() async {
    await SessionCache.setJson(
      SessionCache.kCart,
      cart.items.map((i) => {'id': i.product.id, 'qty': i.quantity}).toList(),
    );
  }

  Future<void> _saveWishlist() async {
    await SessionCache.setJson(SessionCache.kWishlist, wishlist.ids.toList());
  }

  Future<void> _saveOrders() async {
    await SessionCache.setJson(
      SessionCache.kOrders,
      orders
          .map((o) => {
                'id': o.id,
                'apiOrderId': o.apiOrderId,
                'total': o.total,
                'createdAt': o.createdAt.millisecondsSinceEpoch,
                'address': o.address,
                'status': o.status.name,
                'paymentMethod': o.paymentMethod,
                'items': o.items
                    .map((i) => {'id': i.product.id, 'qty': i.quantity})
                    .toList(),
              })
          .toList(),
    );
  }

  Future<void> _saveUser() async {
    await SessionCache.setJson(SessionCache.kUser, {
      'accountId': user.accountId,
      'username': user.username,
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'city': user.city,
      'avatarUrl': user.avatarUrl,
      'role': user.role,
    });
  }

  Future<void> _saveLoyalty() async {
    await SessionCache.setJson(SessionCache.kLoyaltyPoints, loyaltyPoints);
  }

  void _onCartChanged() {
    _saveCart();
    notifyListeners();
  }

  void _onWishlistChanged() {
    _saveWishlist();
    notifyListeners();
  }

  // ── Public API ────────────────────────────────────────────────────────────

  void addToCart(Product product) => cart.add(product);

  void updateUser(UserModel updated) {
    user = updated;
    _saveUser();
    notifyListeners();
  }

  /// Places an order. Tries the API first; falls back to local mock on failure.
  /// Returns the created [Order] so the caller can navigate to the success screen.
  Future<Order> placeOrder(
    String shippingAddress, {
    String? shippingName,
    String? shippingPhone,
    int paymentMethodIndex = 0,
    List<int> voucherIds = const [],
  }) async {
    if (cart.items.isEmpty) {
      return Order(
        id: 'ORD${DateTime.now().millisecondsSinceEpoch}',
        items: const [],
        total: 0,
        createdAt: DateTime.now(),
        address: shippingAddress,
      );
    }

    final result = await OrderService.create(
      items: List.from(cart.items),
      total: cart.total,
      shippingName: shippingName ?? user.name,
      shippingPhone: shippingPhone ?? user.phone,
      shippingAddress: shippingAddress,
      shippingFee: cart.shippingFee,
      paymentMethodIndex: paymentMethodIndex,
      voucherIds: voucherIds,
    );

    final order = result.order;
    orders.insert(0, order);

    final earned = (cart.subtotal / 1000).floor();
    loyaltyPoints += earned;

    // Detach listener so cart.clear() does not fire _onCartChanged prematurely.
    cart.removeListener(_onCartChanged);
    cart.clear();
    cart.addListener(_onCartChanged);

    await Future.wait([
      _saveOrders(),
      _saveCart(),
      _saveLoyalty(),
    ]);

    notifyListeners();
    return order;
  }

  /// Cancels an order locally and, if it has an API id, also via the API.
  Future<void> cancelOrder(String orderId,
      {String cancelReason = 'Khách hàng huỷ'}) async {
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;

    // Optimistic local update
    orders[idx].status = OrderStatus.cancelled;
    _saveOrders();
    notifyListeners();

    // Fire API cancel if this is a real order (non-blocking — we already updated locally)
    final apiId = orders[idx].apiOrderId;
    if (apiId != null) {
      await OrderService.cancel(apiId, cancelReason: cancelReason);
    }
  }

  void reorder(Order order) {
    for (final item in order.items) {
      for (var i = 0; i < item.quantity; i++) {
        cart.add(item.product);
      }
    }
  }

  static Product? _findProduct(String id) {
    try {
      return AppData.allProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  static OrderStatus _parseStatus(String s) => OrderStatus.values.firstWhere(
        (e) => e.name == s,
        orElse: () => OrderStatus.confirmed,
      );

  @override
  void dispose() {
    cart.removeListener(_onCartChanged);
    wishlist.removeListener(_onWishlistChanged);
    cart.dispose();
    wishlist.dispose();
    super.dispose();
  }
}
