import 'package:flutter/foundation.dart';
import 'product.dart';

class WishlistModel extends ChangeNotifier {
  final Set<String> _ids = {};

  bool contains(String productId) => _ids.contains(productId);

  void toggle(Product product) {
    if (_ids.contains(product.id)) {
      _ids.remove(product.id);
    } else {
      _ids.add(product.id);
    }
    notifyListeners();
  }

  int get count => _ids.length;
}
