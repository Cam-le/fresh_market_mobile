import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class CategoryBrowseScreen extends StatefulWidget {
  final ProductCategory category;
  final AppState appState;

  const CategoryBrowseScreen({
    super.key,
    required this.category,
    required this.appState,
  });

  @override
  State<CategoryBrowseScreen> createState() => _CategoryBrowseScreenState();
}

class _CategoryBrowseScreenState extends State<CategoryBrowseScreen> {
  String _sort = 'Nổi bật';
  bool _onlySale = false;
  bool _onlyNew = false;
  int _gridCols = 2;

  static const _sorts = ['Nổi bật', 'Giá thấp', 'Giá cao', 'Đánh giá cao'];

  List<Product> get _filtered {
    var list = List<Product>.from(widget.category.products);
    if (_onlySale) list = list.where((p) => p.isSale).toList();
    if (_onlyNew) list = list.where((p) => p.isNew).toList();
    switch (_sort) {
      case 'Giá thấp':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Giá cao':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Đánh giá cao':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
    return list;
  }

  void _navigateToDetail(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          product: product,
          appState: widget.appState,
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              const Text('Bộ lọc',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              const Text('Sắp xếp theo',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _sorts.map((s) {
                  final sel = _sort == s;
                  return GestureDetector(
                    onTap: () => setModal(() => _sort = s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? AppTheme.primaryGreen : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: sel
                                ? AppTheme.primaryGreen
                                : const Color(0xFFE0E0E0)),
                      ),
                      child: Text(s,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: sel ? Colors.white : AppTheme.textGray)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text('Lọc nhanh',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: _onlySale,
                onChanged: (v) => setModal(() => _onlySale = v!),
                title: const Text('Chỉ hiện hàng đang sale',
                    style: TextStyle(fontSize: 14)),
                activeColor: AppTheme.primaryGreen,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                value: _onlyNew,
                onChanged: (v) => setModal(() => _onlyNew = v!),
                title: const Text('Chỉ hiện sản phẩm mới',
                    style: TextStyle(fontSize: 14)),
                activeColor: AppTheme.primaryGreen,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {});
                    Navigator.pop(ctx);
                  },
                  child: const Text('Áp dụng',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        actions: [
          IconButton(
            onPressed: _showFilterSheet,
            icon: Stack(
              children: [
                const Icon(Icons.tune),
                if (_onlySale || _onlyNew)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: AppTheme.accentOrange, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Sort bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _sorts.map((s) {
                        final sel = _sort == s;
                        return GestureDetector(
                          onTap: () => setState(() => _sort = s),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: sel
                                  ? AppTheme.primaryGreen
                                  : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(s,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: sel
                                        ? Colors.white
                                        : AppTheme.textGray)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // View toggle
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _gridCols = 2),
                      child: Icon(Icons.grid_view_rounded,
                          size: 22,
                          color: _gridCols == 2
                              ? AppTheme.primaryGreen
                              : AppTheme.textLight),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => _gridCols = 1),
                      child: Icon(Icons.view_list_rounded,
                          size: 22,
                          color: _gridCols == 1
                              ? AppTheme.primaryGreen
                              : AppTheme.textLight),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Count + clear filters
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                Text('${products.length} sản phẩm',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textGray)),
                if (_onlySale || _onlyNew) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => setState(() {
                      _onlySale = false;
                      _onlyNew = false;
                    }),
                    child: const Row(children: [
                      Icon(Icons.close, size: 12, color: AppTheme.discountRed),
                      Text('Xoá bộ lọc',
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.discountRed)),
                    ]),
                  ),
                ],
              ],
            ),
          ),
          // Grid / List
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        const Text('Không có sản phẩm phù hợp',
                            style: TextStyle(color: AppTheme.textGray)),
                      ],
                    ),
                  )
                : _gridCols == 2
                    ? GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: products.length,
                        itemBuilder: (ctx, i) {
                          final product = products[i];
                          return ProductCard(
                            product: product,
                            onTap: () => _navigateToDetail(ctx, product),
                            onAddToCart: () =>
                                widget.appState.addToCart(product),
                          );
                        },
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: products.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) => _ListProductTile(
                          product: products[i],
                          appState: widget.appState,
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _ListProductTile extends StatelessWidget {
  final Product product;
  final AppState appState;

  const _ListProductTile({required this.product, required this.appState});

  String _fmt(double p) =>
      '${p.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.')}₫';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  ProductDetailScreen(product: product, appState: appState))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12)),
              child: Image.network(product.imageUrl,
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      width: 110,
                      height: 110,
                      color: const Color(0xFFE8F5E9),
                      child: const Icon(Icons.image_not_supported_outlined,
                          color: AppTheme.primaryGreen))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(product.unit,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textLight)),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.star,
                          size: 13, color: Color(0xFFFFC107)),
                      Text(' ${product.rating} (${product.reviewCount})',
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.textGray)),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      Text(_fmt(product.price),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryGreen)),
                      if (product.originalPrice != null) ...[
                        const SizedBox(width: 8),
                        Text(_fmt(product.originalPrice!),
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textLight,
                                decoration: TextDecoration.lineThrough)),
                      ],
                    ]),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  appState.addToCart(product);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Đã thêm ${product.name} vào giỏ'),
                    backgroundColor: AppTheme.primaryGreen,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ));
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
