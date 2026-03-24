import 'package:flutter/foundation.dart';
import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
}

class CartModel extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  // ── Voucher / discount ──────────────────────────────────────────────────
  String? appliedVoucherCode;
  double discount = 0;

  void applyDiscount({required String code, required double amount}) {
    appliedVoucherCode = code;
    discount = amount;
    notifyListeners();
  }

  void clearDiscount() {
    appliedVoucherCode = null;
    discount = 0;
    notifyListeners();
  }
  // ───────────────────────────────────────────────────────────────────────

  List<CartItem> get items => _items.values.toList();

  int get itemCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _items.values.fold(0, (sum, item) => sum + item.subtotal);

  double get shippingFee => subtotal >= 200000 ? 0 : 25000;

  double get total =>
      (subtotal + shippingFee - discount).clamp(0, double.infinity);

  bool contains(String productId) => _items.containsKey(productId);

  int quantityOf(String productId) => _items[productId]?.quantity ?? 0;

  void add(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity++;
    } else {
      _items[product.id] = CartItem(product: product);
    }
    notifyListeners();
  }

  /// Restores a specific quantity without notifying (used during cache load).
  void forceSet(Product product, int qty) {
    if (qty > 0) _items[product.id] = CartItem(product: product, quantity: qty);
  }

  void remove(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void decrement(String productId) {
    if (!_items.containsKey(productId)) return;
    if (_items[productId]!.quantity <= 1) {
      _items.remove(productId);
    } else {
      _items[productId]!.quantity--;
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    appliedVoucherCode = null;
    discount = 0;
    notifyListeners();
  }
}
