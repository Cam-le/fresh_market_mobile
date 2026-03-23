import 'package:flutter/foundation.dart';
import 'cart.dart';
import 'wishlist.dart';
import 'order.dart';
import 'product.dart';
import 'user.dart';
import '../data/app_data.dart';
import '../services/session_cache.dart';

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
        name: userJson['name'] as String? ?? user.name,
        email: userJson['email'] as String? ?? user.email,
        phone: userJson['phone'] as String? ?? user.phone,
        city: userJson['city'] as String? ?? user.city,
        avatarUrl: userJson['avatarUrl'] as String?,
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
            items.add(CartItem(product: product, quantity: i['qty'] as int? ?? 1));
          }
        }
        if (items.isNotEmpty) {
          orders.add(Order(
            id: o['id'] as String,
            items: items,
            total: (o['total'] as num).toDouble(),
            createdAt: DateTime.fromMillisecondsSinceEpoch(o['createdAt'] as int),
            address: o['address'] as String,
            status: _parseStatus(o['status'] as String? ?? ''),
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
      orders.map((o) => {
        'id': o.id,
        'total': o.total,
        'createdAt': o.createdAt.millisecondsSinceEpoch,
        'address': o.address,
        'status': o.status.name,
        'items': o.items
            .map((i) => {'id': i.product.id, 'qty': i.quantity})
            .toList(),
      }).toList(),
    );
  }

  Future<void> _saveUser() async {
    await SessionCache.setJson(SessionCache.kUser, {
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'city': user.city,
      'avatarUrl': user.avatarUrl,
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

  void placeOrder(String address) {
    if (cart.items.isEmpty) return;
    final order = Order(
      id: 'ORD${DateTime.now().millisecondsSinceEpoch}',
      items: List.from(cart.items),
      total: cart.total,
      createdAt: DateTime.now(),
      address: address,
    );
    orders.insert(0, order);
    final earned = (cart.subtotal / 1000).floor();
    loyaltyPoints += earned;
    _saveLoyalty();
    cart.clear();
    _saveOrders();
    notifyListeners();
  }

  void cancelOrder(String orderId) {
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    orders[idx].status = OrderStatus.cancelled;
    _saveOrders();
    notifyListeners();
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
