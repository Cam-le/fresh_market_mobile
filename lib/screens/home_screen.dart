import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../models/app_state.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/category_section.dart';
import '../widgets/promo_banner.dart';
import '../widgets/app_footer.dart';
import '../screens/cart_screen.dart';
import '../screens/search_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/category_browse_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppState appState;
  const HomeScreen({super.key, required this.appState});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Emoji map: subCategoryName → emoji
  // Falls back to a generic icon for any unlisted subcategory
  static const _subCategoryEmoji = {
    'Rau ăn lá': '🥬',
    'Củ, Quả': '🥕',
    'Nấm, Đậu Hủ': '🍄',
    'Trái Việt Nam': '🍍',
    'Trái Nhập Khẩu': '🍎',
    'Hải Sản': '🐟',
    'Thịt Heo': '🥩',
    'Thịt Bò': '🐄',
    'Thịt Gà, Vịt & Chim': '🍗',
    'Trái Cây Sấy': '🌾',
    'Khô Chế Biến Sẵn': '🦑',
  };

  // Fallback hardcoded chips when subcategories haven't loaded yet
  static const _fallbackChips = [
    {'icon': '🥦', 'label': 'Rau củ', 'catId': 'rau_cu'},
    {'icon': '🍎', 'label': 'Trái cây', 'catId': 'trai_cay'},
    {'icon': '🐟', 'label': 'Hải sản', 'catId': 'hai_san'},
    {'icon': '🥩', 'label': 'Thịt', 'catId': 'thit'},
    {'icon': '🍄', 'label': 'Nấm', 'catId': 'rau_cu'},
    {'icon': '🍍', 'label': 'Trái VN', 'catId': 'trai_cay'},
    {'icon': '🦑', 'label': 'Khô', 'catId': 'thuc_pham_kho'},
    {'icon': '🐄', 'label': 'Bò', 'catId': 'thit'},
  ];

  @override
  Widget build(BuildContext context) {
    final categories = AppData.categories;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                _buildQuickCategories(),
                const SizedBox(height: 8),
              ],
            ),
          ),
          for (final cat in categories)
            SliverToBoxAdapter(
              child: CategorySection(category: cat, appState: widget.appState),
            ),
          const SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height: 8),
                PromoBanner(),
                SizedBox(height: 24),
                AppFooter(),
                SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        final cartCount = widget.appState.cart.itemCount;
        return SliverAppBar(
          expandedHeight: 160,
          pinned: true,
          backgroundColor: const Color(0xFF75B06F),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: const Color(0xFF75B06F)),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.darkGreen.withValues(alpha: 0.9),
                        const Color(0xFF75B06F).withValues(alpha: 0.65),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 100, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ăn Sạch · Sống Khỏe',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Thực phẩm sạch, tươi ngon mỗi ngày',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            collapseMode: CollapseMode.pin,
          ),
          title: const Text(
            'Ăn Sạch Sống Khỏe',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          titleSpacing: 0,
          actions: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CartScreen(appState: widget.appState),
                    ),
                  ),
                  icon: const Icon(Icons.shopping_cart_outlined,
                      color: Colors.white),
                ),
                if (cartCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppTheme.discountRed,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$cartCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              ),
              icon:
                  const Icon(Icons.notifications_outlined, color: Colors.white),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SearchScreen(appState: widget.appState),
                  ),
                ),
                child: const AbsorbPointer(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm thực phẩm...',
                      hintStyle:
                          TextStyle(color: AppTheme.textLight, fontSize: 13),
                      prefixIcon: Icon(Icons.search,
                          color: AppTheme.textLight, size: 20),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickCategories() {
    final subCategories = AppData.subCategories;

    // Use live subcategories if available, otherwise fallback chips
    if (subCategories.isEmpty) {
      return _buildFallbackChips();
    }

    return SizedBox(
      height: 86,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: subCategories.length,
        itemBuilder: (context, index) {
          final sub = subCategories[index];
          final emoji = _subCategoryEmoji[sub.subCategoryName] ?? '🛒';

          return GestureDetector(
            onTap: () => _openSubCategory(sub),
            child: _QuickChip(emoji: emoji, label: sub.subCategoryName),
          );
        },
      ),
    );
  }

  Widget _buildFallbackChips() {
    return SizedBox(
      height: 86,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _fallbackChips.length,
        itemBuilder: (context, index) {
          final chip = _fallbackChips[index];
          return GestureDetector(
            onTap: () {
              final catId = chip['catId']!;
              final category = AppData.categories.firstWhere(
                (c) => c.id == catId,
                orElse: () => AppData.categories.first,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryBrowseScreen(
                    category: category,
                    appState: widget.appState,
                  ),
                ),
              );
            },
            child: _QuickChip(emoji: chip['icon']!, label: chip['label']!),
          );
        },
      ),
    );
  }

  void _openSubCategory(SubCategory sub) {
    // Filter live products by subCategoryName; fall back to parent category
    final filtered = AppData.allProducts
        .where((p) => p.subCategoryName == sub.subCategoryName)
        .toList();

    if (filtered.isNotEmpty) {
      // Build a synthetic ProductCategory scoped to this subcategory
      final syntheticCategory = ProductCategory(
        id: 'sub_${sub.subCategoryId}',
        name: sub.subCategoryName,
        products: filtered,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CategoryBrowseScreen(
            category: syntheticCategory,
            appState: widget.appState,
          ),
        ),
      );
    } else {
      // Products not yet loaded or none in this subcategory —
      // open the parent category instead
      final parentCatId = _resolveCategoryIdFromApiName(sub.categoryName);
      final parentCategory = AppData.categories.firstWhere(
        (c) => c.id == parentCatId,
        orElse: () => AppData.categories.first,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CategoryBrowseScreen(
            category: parentCategory,
            appState: widget.appState,
          ),
        ),
      );
    }
  }

  static String _resolveCategoryIdFromApiName(String apiName) {
    const map = {
      'Rau, Củ & Nấm': 'rau_cu',
      'Trái Cây': 'trai_cay',
      'Thịt, Cá & Hải Sản': 'thit',
      'Thực Phẩm Khô': 'thuc_pham_kho',
    };
    return map[apiName] ?? 'rau_cu';
  }
}

class _QuickChip extends StatelessWidget {
  final String emoji;
  final String label;
  const _QuickChip({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 66,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: AppTheme.textGray,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
