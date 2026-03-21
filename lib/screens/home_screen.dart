import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/category_section.dart';
import '../widgets/promo_banner.dart';
import '../widgets/app_footer.dart';
import '../screens/cart_screen.dart';
import '../screens/search_screen.dart';
import '../screens/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppState appState;
  const HomeScreen({super.key, required this.appState});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    final cats = [
      {'icon': '🥦', 'label': 'Rau củ'},
      {'icon': '🍎', 'label': 'Trái cây'},
      {'icon': '🐟', 'label': 'Hải sản'},
      {'icon': '🥩', 'label': 'Thịt'},
      {'icon': '🥚', 'label': 'Trứng'},
      {'icon': '🧀', 'label': 'Sữa'},
      {'icon': '🌾', 'label': 'Ngũ cốc'},
      {'icon': '🥜', 'label': 'Đậu'},
    ];

    return SizedBox(
      height: 86,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: cats.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {},
            child: SizedBox(
              width: 64,
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
                    child: Text(
                      cats[index]['icon']!,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cats[index]['label']!,
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppTheme.textGray,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
