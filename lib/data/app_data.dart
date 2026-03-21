import '../models/product.dart';
import '../models/news.dart';

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

  // ── News ──────────────────────────────────────────────────────────────────

  static const List<String> newsCategories = [
    'Tất cả',
    'Dinh dưỡng',
    'Công thức',
    'Sức khỏe',
    'Tin tức',
  ];

  static const List<NewsArticle> articles = [
    NewsArticle(
      id: 'n1',
      title: 'Rau xanh mỗi ngày — bí quyết sức khỏe bền vững',
      author: 'Ngọc Hà',
      date: '18/08/2025',
      category: 'Dinh dưỡng',
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800',
      summary:
          'Bổ sung rau xanh vào bữa ăn hằng ngày mang lại vô số lợi ích cho sức khỏe mà nhiều người chưa biết.',
      views: 4112,
      shares: 200,
      sections: [
        NewsSection(
          heading: 'Tại sao rau xanh quan trọng?',
          body:
              'Rau xanh là nguồn cung cấp vitamin, khoáng chất và chất xơ dồi dào. Chúng giúp tăng cường hệ miễn dịch, cải thiện tiêu hóa và giảm nguy cơ mắc các bệnh mãn tính.',
        ),
        NewsSection(
          heading: 'Các loại rau nên ăn hằng ngày',
          body:
              'Cải bó xôi, bông cải xanh, rau muống và cải thảo là những lựa chọn tuyệt vời. Mỗi loại mang một hàm lượng dinh dưỡng khác nhau, giúp cơ thể nhận đủ vi chất cần thiết.',
        ),
        NewsSection(
          heading: 'Cách chế biến giữ dưỡng chất',
          body:
              'Hấp hoặc xào nhanh với lửa lớn là cách tốt nhất để giữ lại vitamin C và các enzyme có lợi. Tránh luộc quá lâu vì sẽ làm mất đi phần lớn giá trị dinh dưỡng.',
        ),
      ],
    ),
    NewsArticle(
      id: 'n2',
      title: 'Cá hồi — siêu thực phẩm cho não bộ và tim mạch',
      author: 'Minh Tuấn',
      date: '15/08/2025',
      category: 'Dinh dưỡng',
      imageUrl:
          'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=800',
      summary:
          'Omega-3 trong cá hồi không chỉ tốt cho tim mạch mà còn hỗ trợ trí nhớ và giảm viêm hiệu quả.',
      views: 3250,
      shares: 145,
      sections: [
        NewsSection(
          heading: 'Omega-3 và não bộ',
          body:
              'DHA — một loại Omega-3 có nhiều trong cá hồi — là thành phần cấu tạo chính của màng tế bào não. Ăn cá hồi đều đặn giúp cải thiện trí nhớ và giảm nguy cơ suy giảm nhận thức theo tuổi tác.',
        ),
        NewsSection(
          heading: 'Lợi ích cho tim mạch',
          body:
              'Các nghiên cứu cho thấy ăn cá béo 2 lần/tuần giúp giảm triglyceride trong máu, hạ huyết áp và giảm nguy cơ đột quỵ đáng kể.',
        ),
      ],
    ),
    NewsArticle(
      id: 'n3',
      title: 'Công thức salad trái cây mùa hè thanh mát',
      author: 'Lan Anh',
      date: '12/08/2025',
      category: 'Công thức',
      imageUrl:
          'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=800',
      summary:
          'Salad trái cây không chỉ đẹp mắt mà còn giàu vitamin, giải nhiệt hiệu quả trong những ngày hè oi bức.',
      views: 2100,
      shares: 310,
      sections: [
        NewsSection(
          heading: 'Nguyên liệu cần chuẩn bị',
          body:
              'Xoài cát, dưa hấu, dứa, nho và bạc hà tươi. Sốt: 2 muỗng canh mật ong, nước cốt 1 quả chanh và một ít gừng tươi bào nhỏ.',
        ),
        NewsSection(
          heading: 'Cách làm',
          body:
              'Cắt tất cả trái cây thành khối vuông vừa ăn. Trộn đều sốt rồi rưới lên trên. Để lạnh 15 phút trước khi dùng để các hương vị hòa quyện. Trang trí với lá bạc hà và vài hạt chia.',
        ),
      ],
    ),
    NewsArticle(
      id: 'n4',
      title: 'Thịt bò thăn — dinh dưỡng và cách chọn mua chuẩn',
      author: 'Văn Khoa',
      date: '10/08/2025',
      category: 'Sức khỏe',
      imageUrl:
          'https://images.unsplash.com/photo-1546964124-0cce460b0c03?w=800',
      summary:
          'Biết cách chọn thịt bò tươi sẽ giúp bữa ăn ngon hơn và đảm bảo an toàn thực phẩm cho cả gia đình.',
      views: 1890,
      shares: 88,
      sections: [
        NewsSection(
          heading: 'Nhận biết thịt bò tươi',
          body:
              'Thịt bò tươi có màu đỏ tươi hoặc đỏ đậm, không có mùi lạ. Mỡ màu vàng nhạt hoặc trắng ngà. Khi ấn ngón tay vào, thịt có độ đàn hồi tốt, không để lại vết lõm.',
        ),
        NewsSection(
          heading: 'Giá trị dinh dưỡng',
          body:
              'Thịt bò thăn cung cấp protein chất lượng cao, sắt heme dễ hấp thu, kẽm và vitamin B12 — các dưỡng chất thiết yếu cho năng lượng và hệ thần kinh.',
        ),
      ],
    ),
    NewsArticle(
      id: 'n5',
      title: 'Xu hướng thực phẩm sạch 2025 — người tiêu dùng đang chọn gì?',
      author: 'Hồng Nhung',
      date: '05/08/2025',
      category: 'Tin tức',
      imageUrl:
          'https://images.unsplash.com/photo-1506484381205-f7945653044d?w=800',
      summary:
          'Người tiêu dùng Việt ngày càng ưu tiên thực phẩm có nguồn gốc rõ ràng và được chứng nhận an toàn.',
      views: 5340,
      shares: 420,
      sections: [
        NewsSection(
          heading: 'Tăng trưởng của thực phẩm hữu cơ',
          body:
              'Thị trường thực phẩm hữu cơ tại Việt Nam tăng trưởng hơn 20% so với năm trước, phản ánh sự thay đổi rõ rệt trong nhận thức của người tiêu dùng về sức khỏe và môi trường.',
        ),
        NewsSection(
          heading: 'Vai trò của công nghệ',
          body:
              'Các ứng dụng đặt hàng thực phẩm sạch, hệ thống truy xuất nguồn gốc bằng QR code và mô hình giao hàng lạnh đang trở thành tiêu chuẩn mới trong ngành.',
        ),
      ],
    ),
    NewsArticle(
      id: 'n6',
      title: '5 loại nấm tốt nhất cho hệ miễn dịch',
      author: 'Bảo Châu',
      date: '01/08/2025',
      category: 'Sức khỏe',
      imageUrl:
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800',
      summary:
          'Nấm không chỉ là nguyên liệu nấu ăn ngon mà còn chứa nhiều hợp chất quý giá giúp tăng cường miễn dịch.',
      views: 2780,
      shares: 175,
      sections: [
        NewsSection(
          heading: 'Nấm linh chi',
          body:
              'Được mệnh danh là "thảo dược của các vị thần", nấm linh chi chứa polysaccharide và triterpenoid giúp điều hòa hệ miễn dịch và chống oxy hóa mạnh.',
        ),
        NewsSection(
          heading: 'Nấm đông cô và nấm hương',
          body:
              'Hai loại nấm phổ biến này chứa lentinan và eritadenine — các hợp chất được chứng minh có khả năng kích thích tế bào miễn dịch và hỗ trợ kiểm soát cholesterol.',
        ),
      ],
    ),
  ];
}
