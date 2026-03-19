# 🥦 Ăn Sạch Sống Khỏe - Fresh Market Flutter App

A fresh food e-commerce app built with Flutter 3.x and Material 3 design, recreated from UI screenshots.

## 📁 File Structure

```
fresh_market/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── theme/
│   │   └── app_theme.dart           # Colors, typography, theme config
│   ├── models/
│   │   └── product.dart             # Product & Category data models
│   ├── data/
│   │   └── app_data.dart            # Mock product/banner data
│   ├── screens/
│   │   ├── home_screen.dart         # Main homepage with sliver app bar
│   │   ├── login_screen.dart        # Đăng Nhập screen
│   │   ├── signup_screen.dart       # Đăng Kí screen
│   │   └── profile_screen.dart      # User profile & settings
│   └── widgets/
│       ├── main_app.dart            # Bottom navigation shell
│       ├── product_card.dart        # Reusable product card
│       ├── category_section.dart    # Category grid section
│       ├── promo_banner.dart        # Promotional banner carousel
│       └── app_footer.dart          # Footer with links & social icons
├── assets/
│   └── images/                      # Place local images here
└── pubspec.yaml
```

## 🚀 How to Run

### Prerequisites
- Flutter SDK 3.x (stable channel)
- Dart SDK ≥ 3.0.0
- Xcode 14+ (for iOS)
- CocoaPods

### Steps

1. **Get dependencies**
   ```bash
   cd fresh_market
   flutter pub get
   ```

2. **iOS setup**
   ```bash
   cd ios
   pod install
   cd ..
   ```

3. **Run on iOS Simulator**
   ```bash
   flutter run -d "iPhone 15 Pro"
   ```

4. **Run on physical device**
   ```bash
   flutter devices          # list connected devices
   flutter run -d <device-id>
   ```

5. **Build for release**
   ```bash
   flutter build ios --release
   ```

## 🎨 Design Highlights

| Feature | Implementation |
|---------|---------------|
| Color scheme | `AppTheme.primaryGreen` (#5B8A3C) with orange accents |
| Home hero | `SliverAppBar` with hero image + parallax collapse |
| Product grid | 4-column `GridView` with image, rating, price |
| Badges | Sale % and NEW badges on product cards |
| Login | Split-panel layout: form left, green logo right |
| Footer | Dark footer with 3-column links + social icons |
| Carousel | `PageView` + `SmoothPageIndicator` for promo banners |

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `cached_network_image` | Efficient network image loading |
| `flutter_rating_bar` | Star ratings display |
| `badges` | Cart item count badges |
| `shimmer` | Loading skeleton effects |
| `smooth_page_indicator` | Banner carousel dots |
| `font_awesome_flutter` | Social media icons |

## 🌐 Notes

- Product images are loaded from Unsplash (requires internet)
- The app uses `Portrait` orientation lock for mobile
- Login/Signup use the split-screen layout matching your design screenshots
- Footer widget (`AppFooter`) can be added to any scrollable list's bottom
