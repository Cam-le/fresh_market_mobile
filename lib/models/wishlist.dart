import 'package:flutter/foundation.dart';
import 'product.dart';

class WishlistModel extends ChangeNotifier {
  final Set<String> _ids = {};

  Set<String> get ids => Set.unmodifiable(_ids);

  bool contains(String productId) => _ids.contains(productId);

  void toggle(Product product) {
    if (_ids.contains(product.id)) {
      _ids.remove(product.id);
    } else {
      _ids.add(product.id);
    }
    notifyListeners();
  }

  /// Restores an id without notifying (used during cache load).
  void forceAdd(Product product) => _ids.add(product.id);

  int get count => _ids.length;
}
