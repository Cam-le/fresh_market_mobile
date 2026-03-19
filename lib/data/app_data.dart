import '../models/product.dart';

class AppData {
  static const List<Product> vegetables = [
    Product(
      id: 'v1',
      name: 'Cải thảo',
      price: 15000,
      originalPrice: 20000,
      rating: 4.5,
      reviewCount: 120,
      imageUrl:
          'https://images.unsplash.com/photo-1584270354949-c26b0d5b4a0c?w=300',
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
          'https://images.unsplash.com/photo-1598030343246-0a2c1e2f99c7?w=300',
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
          'https://images.unsplash.com/photo-1587411768638-ec71f8e33b78?w=300',
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
          'https://images.unsplash.com/photo-1570586437263-ab629fccc818?w=300',
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
          'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=300',
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
          'https://images.unsplash.com/photo-1546094096-0df4bcabd337?w=300',
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

  static const List<Product> fruits = [
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
          'https://images.unsplash.com/photo-1562547256-2c5ee93714f6?w=300',
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

  static const List<Product> seafood = [
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
          'https://images.unsplash.com/photo-1609501676725-7186f017a4b7?w=300',
      unit: '1kg',
      isSale: true,
      category: 'hai_san',
    ),
  ];

  static const List<Product> meat = [
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
          'https://images.unsplash.com/photo-1546964124-0cce460b0c03?w=300',
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

  static List<ProductCategory> get categories => [
        const ProductCategory(
          id: 'rau_cu',
          name: 'Rau Củ & Nấm',
          products: vegetables,
        ),
        const ProductCategory(
          id: 'trai_cay',
          name: 'Trái Cây Tươi Ngon',
          products: fruits,
        ),
        const ProductCategory(
          id: 'hai_san',
          name: 'Hải Sản & Thủy Sản',
          products: seafood,
        ),
        const ProductCategory(
          id: 'thit',
          name: 'Thịt, Cá, Trứng & Hải Sản',
          products: meat,
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
