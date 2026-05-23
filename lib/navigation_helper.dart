import 'dart:ui';
import 'package:flutter/material.dart';
import 'presentation/widgets/glass_container.dart';

/// Tüm sayfalar arasında paylaşılan renk paleti
class AppColors {
  // Arka Plan (Light Mode: #e9edf05b, Dark Mode: #0B1020)
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color background = Color(0xFF0B1020); // Default to Dark Mode as requested
  
  // Surface colors for Dark Mode
  static const Color surface = Color(0xFF131A2E);
  static const Color surfaceContainer = Color(0xFF1B233E); // Slightly lighter than background card
  static const Color surfaceContainerHigh = Color(0xFF242F50);
  static const Color surfaceContainerHighest = Color(0xFF2E3A60);
  static const Color surfaceContainerLow = Color(0xFF080C18);

  // Ana Renk (Primary): #00C896 (Mint Green matching financialGreen)
  static const Color primary = Color(0xFF00C896);
  static const Color primaryContainer = Color(0xFF005E46); // Darker mint
  
  // Gelir (Income): #00C896
  static const Color secondary = Color(0xFF00E5FF); // Neon Cyan
  static const Color income = Color(0xFF00C896); // Mint
  
  // Gider (Expense): Neon Red/Pink
  static const Color error = Color(0xFFFF4A5A); 
  static const Color expense = Color(0xFFFF4A5A);

  // Tasarruf / Yatırım: Neon Purple #7C5CFF
  static const Color tertiary = Color(0xFF7C5CFF);
  static const Color savings = Color(0xFF7C5CFF);
  static const Color tertiaryContainer = Color(0xFF5338B3);
  static const Color secondaryContainer = Color(0xFF007C8C);

  // Bilgilendirme: Neon Cyan #00E5FF
  static const Color info = Color(0xFF00E5FF);

  // Text Colors
  static const Color onBackground = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFFFFFFFF);
  static const Color onSurfaceVariant = Color(0xFF94A3B8); // Slate 400
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFE0F2FE);
}

/// Responsive boyut hesaplama yardımcıları
class AppSizes {
  final BuildContext context;
  late final double screenWidth;
  late final double screenHeight;
  late final double scaleFactor;

  AppSizes(this.context) {
    final size = MediaQuery.sizeOf(context);
    screenWidth = size.width;
    screenHeight = size.height;
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

const Map<int, String> _navRoutes = {
  0: '/',
  1: '/transactions',
  2: '/assistant',
  3: '/health',
  4: '/budget',
  5: '/analytics',
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
  final activeColor = Theme.of(context).colorScheme.primary;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return AppBar(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.8),
    elevation: 0,
    scrolledUnderElevation: 4,
    automaticallyImplyLeading: false,
    leading: showBackButton
        ? IconButton(
            icon: Icon(Icons.arrow_back, color: activeColor),
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
      child: Container(color: Theme.of(context).dividerColor, height: 1),
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
              color: Theme.of(context).colorScheme.surfaceContainer,
              border: Border.all(color: activeColor.withValues(alpha: 0.3)),
            ),
            child: Icon(Icons.person, color: activeColor, size: sizes.sp(18)),
          ),
        ),
        SizedBox(width: sizes.sp(12)),
        Text(
          title,
          style: TextStyle(
            fontSize: sizes.sp(24),
            fontWeight: FontWeight.w700,
            color: activeColor,
            letterSpacing: -0.5,
          ),
        ),
      ],
    ),
    actions: [
      IconButton(
        icon: Icon(Icons.notifications_outlined, color: activeColor),
        onPressed: () {},
      ),
      SizedBox(width: sizes.sp(8)),
    ],
  );
}

/// Ortak Bottom Navigation Bar builder
Widget buildBottomNavBar(BuildContext context, int selectedIndex) {
  final sizes = AppSizes(context);
  final bottomPadding = MediaQuery.paddingOf(context).bottom;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return GlassContainer(
    margin: EdgeInsets.only(left: sizes.sp(16), right: sizes.sp(16), bottom: sizes.sp(16) + bottomPadding),
    height: sizes.sp(68),
    borderRadius: 34,
    blur: 24.0,
    gradientColors: isDark
        ? [
            Colors.white.withValues(alpha: 0.10),
            Colors.white.withValues(alpha: 0.03),
          ]
        : [
            Colors.black.withValues(alpha: 0.05),
            Colors.black.withValues(alpha: 0.01),
          ],
    border: Border.all(
      color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.08),
      width: 1.2,
    ),
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sizes.sp(8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavBarItem(
              index: 0,
              selectedIndex: selectedIndex,
              icon: Icons.dashboard,
              label: 'Ana Sayfa',
              sizes: sizes,
              onTap: () => navigateToIndex(context, 0),
            ),
            _NavBarItem(
              index: 1,
              selectedIndex: selectedIndex,
              icon: Icons.receipt_long,
              label: 'Harcamalar',
              sizes: sizes,
              onTap: () => navigateToIndex(context, 1),
            ),
            _NavBarItem(
              index: 2,
              selectedIndex: selectedIndex,
              icon: Icons.auto_awesome,
              label: 'Asistan',
              sizes: sizes,
              onTap: () => navigateToIndex(context, 2),
            ),
            _NavBarItem(
              index: 3,
              selectedIndex: selectedIndex,
              icon: Icons.health_and_safety,
              label: 'Sağlık',
              sizes: sizes,
              onTap: () => navigateToIndex(context, 3),
            ),
            _NavBarItem(
              index: 4,
              selectedIndex: selectedIndex,
              icon: Icons.account_balance_wallet,
              label: 'Bütçe',
              sizes: sizes,
              onTap: () => navigateToIndex(context, 4),
            ),
            _NavBarItem(
              index: 5,
              selectedIndex: selectedIndex,
              icon: Icons.insights,
              label: 'Analitik',
              sizes: sizes,
              onTap: () => navigateToIndex(context, 5),
            ),
          ],
        ),
      ),
    ),
  );
}

class _NavBarItem extends StatefulWidget {
  final int index;
  final int selectedIndex;
  final IconData icon;
  final String label;
  final AppSizes sizes;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.index,
    required this.selectedIndex,
    required this.icon,
    required this.label,
    required this.sizes,
    required this.onTap,
  });

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.selectedIndex == widget.index;
    final activeColor = Theme.of(context).colorScheme.primary;

    Color iconTextColor;
    if (isSelected) {
      iconTextColor = activeColor;
    } else if (_isHovered) {
      iconTextColor = activeColor.withValues(alpha: 0.95);
    } else {
      iconTextColor = Theme.of(context).colorScheme.onSurfaceVariant;
    }

    Decoration decoration;
    if (isSelected) {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            activeColor.withValues(alpha: 0.22),
            activeColor.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: activeColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: activeColor.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          )
        ],
      );
    } else if (_isHovered) {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            activeColor.withValues(alpha: 0.10),
            activeColor.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: activeColor.withValues(alpha: 0.25),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: activeColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      );
    } else {
      decoration = BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.transparent,
          width: 1.0,
        ),
      );
    }

    return InkWell(
      onTap: widget.onTap,
      onHover: (hovered) {
        setState(() {
          _isHovered = hovered;
        });
      },
      hoverColor: Colors.transparent,
      highlightColor: activeColor.withValues(alpha: 0.1),
      splashColor: activeColor.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: widget.sizes.sp(12),
          vertical: widget.sizes.sp(8),
        ),
        decoration: decoration,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.10 : (_isHovered ? 1.05 : 1.0),
              duration: const Duration(milliseconds: 200),
              child: Icon(widget.icon, color: iconTextColor, size: widget.sizes.sp(22)),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: (isSelected || _isHovered)
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: widget.sizes.sp(6)),
                        Text(
                          widget.label,
                          style: TextStyle(
                            color: iconTextColor,
                            fontSize: widget.sizes.sp(11),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
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
  final theme = Theme.of(sizes.context);

  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(sizes.sp(32)),
    decoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
    ),
    child: Column(
      children: [
        Container(
          width: sizes.sp(64),
          height: sizes.sp(64),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
          ),
          child: Icon(icon, color: theme.colorScheme.primary.withValues(alpha: 0.5), size: sizes.sp(32)),
        ),
        SizedBox(height: sizes.sp(16)),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: sizes.sp(16),
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: sizes.sp(8)),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: sizes.sp(13),
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        if (onAction != null && actionLabel != null) ...[
          SizedBox(height: sizes.sp(20)),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
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

