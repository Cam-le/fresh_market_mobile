import 'package:flutter/foundation.dart';
import 'cart.dart';
import 'wishlist.dart';
import 'order.dart';
import 'product.dart';
import 'user.dart';

class AppState extends ChangeNotifier {
  final CartModel cart = CartModel();
  final WishlistModel wishlist = WishlistModel();
  final List<Order> orders = [];

  UserModel user = UserModel(
    name: 'Nguyễn Văn A',
    email: 'example@gmail.com',
    phone: '0901 234 567',
    city: 'TP. Hồ Chí Minh',
  );

  AppState() {
    cart.addListener(notifyListeners);
    wishlist.addListener(notifyListeners);
  }

  void addToCart(Product product) => cart.add(product);

  void updateUser(UserModel updated) {
    user = updated;
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
    cart.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    cart.removeListener(notifyListeners);
    wishlist.removeListener(notifyListeners);
    cart.dispose();
    wishlist.dispose();
    super.dispose();
  }
}
