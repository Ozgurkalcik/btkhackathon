import 'dart:ui';
import 'package:flutter/material.dart';

/// Tüm sayfalar arasında paylaşılan renk paleti
class AppColors {
  static const Color background = Color(0xFF101415);
  static const Color surface = Color(0xFF101415);
  static const Color surfaceContainer = Color(0xFF1D2022);
  static const Color surfaceContainerHigh = Color(0xFF272A2C);
  static const Color surfaceContainerHighest = Color(0xFF323537);
  static const Color surfaceContainerLow = Color(0xFF191C1E);

  static const Color primary = Color(0xFF4EDEA3);
  static const Color primaryContainer = Color(0xFF10B981);
  static const Color secondary = Color(0xFFFFB2B9);
  static const Color secondaryContainer = Color(0xFF891933);
  static const Color tertiary = Color(0xFFFFB95F);
  static const Color tertiaryContainer = Color(0xFFE29100);
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000a);

  static const Color onBackground = Color(0xFFE0E3E5);
  static const Color onSurface = Color(0xFFE0E3E5);
  static const Color onSurfaceVariant = Color(0xFFBBCABF);
  static const Color onPrimary = Color(0xFF003824);
  static const Color onPrimaryContainer = Color(0xFF00422B);
}

/// Responsive boyut hesaplama yardımcıları
class AppSizes {
  final BuildContext context;
  late final double screenWidth;
  late final double screenHeight;
  late final double scaleFactor;

  AppSizes(this.context) {
    final mq = MediaQuery.of(context);
    screenWidth = mq.size.width;
    screenHeight = mq.size.height;
    // 375 genişlik referans alınarak ölçeklendirme (iPhone SE bazlı)
    scaleFactor = (screenWidth / 375).clamp(0.8, 1.4);
  }

  double sp(double size) => size * scaleFactor;
  double hp(double fraction) => screenWidth * fraction;
  double vp(double fraction) => screenHeight * fraction;

  EdgeInsets get screenPadding => EdgeInsets.symmetric(horizontal: sp(20));

  bool get isSmallScreen => screenWidth < 360;
  bool get isMediumScreen => screenWidth >= 360 && screenWidth < 600;
  bool get isLargeScreen => screenWidth >= 600;

  int get gridCrossAxisCount {
    if (screenWidth >= 600) return 3;
    if (screenWidth >= 420) return 2;
    return 2;
  }
}

/// Sayfa index -> route mapping
const Map<int, String> _navRoutes = {
  0: '/',
  1: '/health',
  2: '/scan',
  3: '/analytics',
  4: '/budget',
};

/// Aktif sayfayı route'dan belirle
int getSelectedIndexFromRoute(BuildContext context) {
  final route = ModalRoute.of(context)?.settings.name;
  for (final entry in _navRoutes.entries) {
    if (entry.value == route) return entry.key;
  }
  return 0; // Varsayılan: Dashboard
}

/// Sayfa geçişi yap (aynı sayfadaysa geçiş yapma)
void navigateToIndex(BuildContext context, int index) {
  final currentRoute = ModalRoute.of(context)?.settings.name;
  final targetRoute = _navRoutes[index];
  if (targetRoute != null && targetRoute != currentRoute) {
    Navigator.pushReplacementNamed(context, targetRoute);
  }
}

/// Ortak AppBar builder — tüm sayfalar için kullanılır
AppBar buildCommonAppBar({
  required String title,
  bool showBackButton = false,
  VoidCallback? onBackPressed,
  required BuildContext context,
}) {
  final sizes = AppSizes(context);

  return AppBar(
    backgroundColor: AppColors.background.withOpacity(0.8),
    elevation: 0,
    scrolledUnderElevation: 4,
    automaticallyImplyLeading: false,
    leading: showBackButton
        ? IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: onBackPressed ?? () => Navigator.maybePop(context),
          )
        : null,
    flexibleSpace: ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(color: Colors.transparent),
      ),
    ),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(color: Colors.white.withOpacity(0.1), height: 1),
    ),
    title: Row(
      children: [
        GestureDetector(
          onTap: () {
            final currentRoute = ModalRoute.of(context)?.settings.name;
            if (currentRoute != '/profile') {
              Navigator.pushReplacementNamed(context, '/profile');
            }
          },
          child: Container(
            width: sizes.sp(32),
            height: sizes.sp(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerHigh,
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Icon(Icons.person, color: AppColors.primary, size: sizes.sp(18)),
          ),
        ),
        SizedBox(width: sizes.sp(12)),
        Text(
          title,
          style: TextStyle(
            fontSize: sizes.sp(24),
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
      ],
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
        onPressed: () {},
      ),
      SizedBox(width: sizes.sp(8)),
    ],
  );
}

/// Ortak Bottom Navigation Bar builder
Widget buildBottomNavBar(BuildContext context, int selectedIndex) {
  final sizes = AppSizes(context);
  final bottomPadding = MediaQuery.of(context).padding.bottom;

  return Container(
    height: sizes.sp(72) + bottomPadding,
    padding: EdgeInsets.only(bottom: bottomPadding),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainer,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 12,
          offset: const Offset(0, -4),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNavItem(context, selectedIndex, 0, Icons.dashboard, 'Panel', sizes),
        _buildNavItem(context, selectedIndex, 1, Icons.health_and_safety, 'Sağlık', sizes),
        _buildNavItem(context, selectedIndex, 2, Icons.center_focus_strong, 'Tarama', sizes),
        _buildNavItem(context, selectedIndex, 3, Icons.insights, 'Analiz', sizes),
        _buildNavItem(context, selectedIndex, 4, Icons.account_balance_wallet, 'Bütçe', sizes),
      ],
    ),
  );
}

Widget _buildNavItem(BuildContext context, int selectedIndex, int index,
    IconData icon, String label, AppSizes sizes) {
  final isSelected = selectedIndex == index;
  final color = isSelected ? AppColors.primary : AppColors.onSurfaceVariant;

  return InkWell(
    onTap: () => navigateToIndex(context, index),
    borderRadius: BorderRadius.circular(12),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: sizes.sp(8), vertical: sizes.sp(6)),
      transform: Matrix4.translationValues(0, isSelected ? -2 : 0, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: sizes.sp(22)),
          SizedBox(height: sizes.sp(3)),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: sizes.sp(10),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );
}

/// Boş durum widget'ı — veri yokken gösterilir
Widget buildEmptyState({
  required IconData icon,
  required String title,
  required String subtitle,
  required AppSizes sizes,
  VoidCallback? onAction,
  String? actionLabel,
}) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(sizes.sp(32)),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white.withOpacity(0.05)),
    ),
    child: Column(
      children: [
        Container(
          width: sizes.sp(64),
          height: sizes.sp(64),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.1),
          ),
          child: Icon(icon, color: AppColors.primary.withOpacity(0.5), size: sizes.sp(32)),
        ),
        SizedBox(height: sizes.sp(16)),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: sizes.sp(16),
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        SizedBox(height: sizes.sp(8)),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: sizes.sp(13),
            color: AppColors.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        if (onAction != null && actionLabel != null) ...[
          SizedBox(height: sizes.sp(20)),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(
                horizontal: sizes.sp(24),
                vertical: sizes.sp(12),
              ),
            ),
            child: Text(actionLabel, style: TextStyle(fontSize: sizes.sp(14), fontWeight: FontWeight.w600)),
          ),
        ],
      ],
    ),
  );
}
