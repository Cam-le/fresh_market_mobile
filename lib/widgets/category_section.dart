import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import '../screens/product_detail_screen.dart';
import '../screens/category_browse_screen.dart';
import 'product_card.dart';

class CategorySection extends StatelessWidget {
  final ProductCategory category;
  final AppState appState;

  const CategorySection(
      {super.key, required this.category, required this.appState});

  @override
  Widget build(BuildContext context) {
    const double gridPadding = 12;
    const double gap = 8;
    const int columns = 4;
    const double contentHeight = 88;

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth =
        (screenWidth - gridPadding * 2 - gap * (columns - 1)) / columns;
    final aspectRatio = cardWidth / (cardWidth + contentHeight);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => CategoryBrowseScreen(
                          category: category, appState: appState)),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: gridPadding),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: aspectRatio,
            crossAxisSpacing: gap,
            mainAxisSpacing: gap,
          ),
          itemCount: category.products.length,
          itemBuilder: (context, index) {
            final product = category.products[index];
            return ProductCard(
              product: product,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ProductDetailScreen(product: product, appState: appState),
                ),
              ),
              onAddToCart: () {
                appState.addToCart(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã thêm ${product.name} vào giỏ'),
                    duration: const Duration(seconds: 1),
                    backgroundColor: AppTheme.primaryGreen,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
