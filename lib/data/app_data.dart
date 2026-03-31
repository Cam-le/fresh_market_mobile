import '../models/product.dart';

class PromoVoucher {
  final String code;
  final String title;
  final String description;
  final String expiry;
  final int discount;
  final bool isPercent;
  final int minOrder;
  final int maxDiscount;

  const PromoVoucher({
    required this.code,
    required this.title,
    required this.description,
    required this.expiry,
    required this.discount,
    required this.isPercent,
    required this.minOrder,
    this.maxDiscount = 0,
  });

  int computeDiscount(double subtotal) {
    if (subtotal < minOrder) return 0;
    if (isPercent) {
      final raw = (subtotal * discount / 100).round();
      return (maxDiscount > 0 && raw > maxDiscount) ? maxDiscount : raw;
    }
    return discount;
  }
}

class AppData {
  // ── Live cache (written by ProductService after a successful API fetch) ─────
  // When non-null, allProducts and categories use live data instead of mock.
  static List<Product>? _liveProducts;
  static List<ProductCategory>? _liveCategories;

  /// Called by ProductService after a successful API fetch.
  static void setLiveData({
    required List<Product> products,
    required List<ProductCategory> categories,
  }) {
    _liveProducts = products;
    _liveCategories = categories;
  }

  /// Clears live cache — reverts to mock data (e.g. on logout).
  static void clearLiveData() {
    _liveProducts = null;
    _liveCategories = null;
  }

  // ── Public getters — live data takes priority, mock is the fallback ─────────

  static List<Product> get allProducts =>
      _liveProducts ?? [..._vegetables, ..._fruits, ..._seafood, ..._meat];

  static List<ProductCategory> get categories =>
      _liveCategories ??
      [
        const ProductCategory(
            id: 'rau_cu', name: 'Rau Củ & Nấm', products: _vegetables),
        const ProductCategory(
            id: 'trai_cay', name: 'Trái Cây Tươi Ngon', products: _fruits),
        const ProductCategory(
            id: 'hai_san', name: 'Hải Sản & Thủy Sản', products: _seafood),
        const ProductCategory(
            id: 'thit', name: 'Thịt, Cá, Trứng & Hải Sản', products: _meat),
      ];

  // Legacy named getters for any code that still references them directly
  static List<Product> get vegetables =>
      _liveProducts?.where((p) => p.category == 'rau_cu').toList() ??
      _vegetables;
  static List<Product> get fruits =>
      _liveProducts?.where((p) => p.category == 'trai_cay').toList() ?? _fruits;
  static List<Product> get seafood =>
      _liveProducts?.where((p) => p.category == 'hai_san').toList() ?? _seafood;
  static List<Product> get meat =>
      _liveProducts?.where((p) => p.category == 'thit').toList() ?? _meat;

  // ── Static mock data (unchanged — always available as fallback) ─────────────

  static const List<Product> _vegetables = [
    Product(
      id: 'v1',
      name: 'Cải thảo',
      price: 15000,
      originalPrice: 20000,
      rating: 4.5,
      reviewCount: 120,
      imageUrl:
          'https://images.unsplash.com/photo-1594282486552-05b4d80fbb9f?w=300',
      unit: '500g',
      isSale: true,
      category: 'rau_cu',
    ),
    Product(
      id: 'v2',
      name: 'Bắp cải xanh',
      price: 12000,
      rating: 4.3,
      reviewCount: 85,
      imageUrl:
          'https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=300',
      unit: '500g',
      category: 'rau_cu',
    ),
    Product(
      id: 'v3',
      name: 'Dưa leo',
      price: 8000,
      rating: 4.7,
      reviewCount: 200,
      imageUrl:
          'https://images.unsplash.com/photo-1449300079323-02e209d9d3a6?w=300',
      unit: '500g',
      isNew: true,
      category: 'rau_cu',
    ),
    Product(
      id: 'v4',
      name: 'Bí ngô',
      price: 18000,
      rating: 4.4,
      reviewCount: 65,
      imageUrl:
          'https://images.unsplash.com/photo-1506917728037-b6af01a7d403?w=300',
      unit: '1kg',
      category: 'rau_cu',
    ),
    Product(
      id: 'v5',
      name: 'Rau muống',
      price: 5000,
      rating: 4.2,
      reviewCount: 150,
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=300',
      unit: 'Bó',
      category: 'rau_cu',
    ),
    Product(
      id: 'v6',
      name: 'Cà chua bi',
      price: 22000,
      originalPrice: 30000,
      rating: 4.8,
      reviewCount: 310,
      imageUrl:
          'https://images.unsplash.com/photo-1592841200221-a6898f307baa?w=300',
      unit: '500g',
      isSale: true,
      category: 'rau_cu',
    ),
    Product(
      id: 'v7',
      name: 'Khoai tây',
      price: 14000,
      rating: 4.1,
      reviewCount: 95,
      imageUrl:
          'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=300',
      unit: '1kg',
      category: 'rau_cu',
    ),
    Product(
      id: 'v8',
      name: 'Hành tây',
      price: 10000,
      rating: 4.3,
      reviewCount: 140,
      imageUrl:
          'https://images.unsplash.com/photo-1508747703725-719777637510?w=300',
      unit: '500g',
      category: 'rau_cu',
    ),
  ];

  static const List<Product> _fruits = [
    Product(
      id: 'f1',
      name: 'Xoài cát Hòa Lộc',
      price: 45000,
      originalPrice: 60000,
      rating: 4.9,
      reviewCount: 520,
      imageUrl:
          'https://images.unsplash.com/photo-1553279768-865429fa0078?w=300',
      unit: '1kg',
      isSale: true,
      category: 'trai_cay',
    ),
    Product(
      id: 'f2',
      name: 'Cam sành',
      price: 28000,
      rating: 4.6,
      reviewCount: 280,
      imageUrl:
          'https://images.unsplash.com/photo-1547514701-42782101795e?w=300',
      unit: '1kg',
      category: 'trai_cay',
    ),
    Product(
      id: 'f3',
      name: 'Dừa tươi',
      price: 20000,
      rating: 4.7,
      reviewCount: 180,
      imageUrl:
          'https://images.unsplash.com/photo-1490885578174-acda8905c2c6?w=300',
      unit: 'Trái',
      isNew: true,
      category: 'trai_cay',
    ),
    Product(
      id: 'f4',
      name: 'Thanh long đỏ',
      price: 35000,
      rating: 4.5,
      reviewCount: 165,
      imageUrl:
          'https://images.unsplash.com/photo-1527325678964-54921661f888?w=300',
      unit: '1kg',
      category: 'trai_cay',
    ),
  ];

  static const List<Product> _seafood = [
    Product(
      id: 's1',
      name: 'Tôm sú tươi',
      price: 180000,
      originalPrice: 220000,
      rating: 4.8,
      reviewCount: 340,
      imageUrl:
          'https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?w=300',
      unit: '500g',
      isSale: true,
      category: 'hai_san',
    ),
    Product(
      id: 's2',
      name: 'Cá thu',
      price: 120000,
      rating: 4.6,
      reviewCount: 210,
      imageUrl:
          'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=300',
      unit: '1kg',
      category: 'hai_san',
    ),
    Product(
      id: 's3',
      name: 'Mực ống',
      price: 95000,
      rating: 4.4,
      reviewCount: 155,
      imageUrl:
          'https://images.unsplash.com/photo-1559732277-7453b141e3a1?w=300',
      unit: '500g',
      category: 'hai_san',
    ),
    Product(
      id: 's4',
      name: 'Cua biển',
      price: 250000,
      originalPrice: 300000,
      rating: 4.9,
      reviewCount: 420,
      imageUrl:
          'https://images.unsplash.com/photo-1615141982883-c7ad0e69fd62?w=300',
      unit: '1kg',
      isSale: true,
      category: 'hai_san',
    ),
  ];

  static const List<Product> _meat = [
    Product(
      id: 'm1',
      name: 'Thịt ba chỉ heo',
      price: 85000,
      rating: 4.7,
      reviewCount: 280,
      imageUrl:
          'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=300',
      unit: '500g',
      category: 'thit',
    ),
    Product(
      id: 'm2',
      name: 'Sườn non heo',
      price: 95000,
      originalPrice: 120000,
      rating: 4.8,
      reviewCount: 190,
      imageUrl:
          'https://images.unsplash.com/photo-1529692236671-f1f6cf9683ba?w=300',
      unit: '500g',
      isSale: true,
      category: 'thit',
    ),
    Product(
      id: 'm3',
      name: 'Thịt bò thăn',
      price: 160000,
      rating: 4.6,
      reviewCount: 145,
      imageUrl:
          'https://images.unsplash.com/photo-1603048588665-791ca8aea617?w=300',
      unit: '500g',
      category: 'thit',
    ),
    Product(
      id: 'm4',
      name: 'Gà ta nguyên con',
      price: 120000,
      rating: 4.5,
      reviewCount: 230,
      imageUrl:
          'https://images.unsplash.com/photo-1587593810167-a84920ea0781?w=300',
      unit: 'Con ~1.2kg',
      category: 'thit',
    ),
  ];

  // ── Vouchers & Banners (unchanged) ──────────────────────────────────────────

  static const List<PromoVoucher> vouchers = [
    PromoVoucher(
      code: 'WELCOME50',
      title: 'Chào mừng thành viên mới',
      description: 'Giảm 50.000đ cho đơn hàng từ 200.000đ',
      expiry: '31/03/2026',
      discount: 50000,
      isPercent: false,
      minOrder: 200000,
    ),
    PromoVoucher(
      code: 'FREESHIP',
      title: 'Miễn phí vận chuyển',
      description: 'Giảm 25.000đ (tương đương phí ship) không giới hạn đơn',
      expiry: '15/04/2026',
      discount: 25000,
      isPercent: false,
      minOrder: 0,
    ),
    PromoVoucher(
      code: 'SUMMER20',
      title: 'Khuyến mãi hè 2026',
      description: 'Giảm 20% tối đa 100.000đ cho đơn từ 300.000đ',
      expiry: '30/06/2026',
      discount: 20,
      isPercent: true,
      minOrder: 300000,
      maxDiscount: 100000,
    ),
    PromoVoucher(
      code: 'VIP30',
      title: 'Ưu đãi thành viên VIP',
      description: 'Giảm 30% tối đa 150.000đ cho đơn từ 500.000đ',
      expiry: '31/12/2026',
      discount: 30,
      isPercent: true,
      minOrder: 500000,
      maxDiscount: 150000,
    ),
  ];

  static const List<Map<String, String>> banners = [
    {
      'title': 'Ưu Đãi Tết 2026',
      'subtitle': 'Giảm đến 50%',
      'imageUrl':
          'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800',
      'buttonText': 'Xem ngay',
    },
    {
      'title': 'Rau Sạch Mỗi Ngày',
      'subtitle': 'Giao hàng tận nhà',
      'imageUrl':
          'https://images.unsplash.com/photo-1506484381205-f7945653044d?w=800',
      'buttonText': 'Đặt ngay',
    },
  ];
}
