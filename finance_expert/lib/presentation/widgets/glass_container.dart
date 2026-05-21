import 'dart:ui';
import 'package:flutter/material.dart';

/// Premium Glassmorphism (Cam Efekti) Tasarım Kutusu
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double blur;
  final double borderRadius;
  final Color? color;
  final List<Color>? gradientColors;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Border? border;
  final BoxBorder? customBorder;
  final List<BoxShadow>? shadow;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.blur = 16.0,
    this.borderRadius = 16.0,
    this.color,
    this.gradientColors,
    this.padding,
    this.margin,
    this.border,
    this.customBorder,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Işık kırılmasını simüle eden gradyan renkleri
    final defaultGradientColors = isDark
        ? [
            Colors.white.withOpacity(0.07),
            Colors.white.withOpacity(0.02),
          ]
        : [
            Colors.black.withOpacity(0.04),
            Colors.black.withOpacity(0.01),
          ];

    final backgroundGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: gradientColors ?? defaultGradientColors,
    );

    // İnce şeffaf cam sınır çizgisi (ışık yansıması)
    final defaultBorder = Border.all(
      color: isDark
          ? Colors.white.withOpacity(0.12)
          : Colors.black.withOpacity(0.08),
      width: 1.0,
    );

    // Derinlik hissi veren yumuşak gölge
    final defaultShadow = [
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ];

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadow ?? defaultShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color,
              gradient: color == null ? backgroundGradient : null,
              borderRadius: BorderRadius.circular(borderRadius),
              border: customBorder ?? border ?? defaultBorder,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Hover durumunda yukarı doğru hafifçe yükselen (lift) ve neon ışıma efekti kazanan Cam Kutusu
class HoverGlassContainer extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double blur;
  final double borderRadius;
  final Color? color;
  final List<Color>? gradientColors;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? glowColor;
  final double lift;
  final VoidCallback? onTap;

  const HoverGlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.blur = 16.0,
    this.borderRadius = 16.0,
    this.color,
    this.gradientColors,
    this.padding,
    this.margin,
    this.glowColor,
    this.lift = 6.0,
    this.onTap,
  });

  @override
  State<HoverGlassContainer> createState() => _HoverGlassContainerState();
}

class _HoverGlassContainerState extends State<HoverGlassContainer> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Default glow color matches primary
    final activeGlowColor = widget.glowColor ?? Theme.of(context).colorScheme.primary;

    final defaultGradientColors = isDark
        ? [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ]
        : [
            Colors.black.withOpacity(0.04),
            Colors.black.withOpacity(0.01),
          ];

    final backgroundGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: widget.gradientColors ?? defaultGradientColors,
    );

    // Dynamic glow border on hover
    final activeBorder = Border.all(
      color: _isHovered 
          ? activeGlowColor.withOpacity(0.5) 
          : (isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.08)),
      width: _isHovered ? 1.5 : 1.0,
    );

    // Hover shadow has a strong neon glow
    final activeShadow = _isHovered
        ? [
            BoxShadow(
              color: activeGlowColor.withOpacity(0.4),
              blurRadius: 20,
              offset: Offset(0, widget.lift),
              spreadRadius: -2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
              blurRadius: 16,
              offset: Offset(0, widget.lift + 2),
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ];

    Widget current = InkWell(
      onTap: widget.onTap,
      onHover: (value) {
        setState(() {
          _isHovered = value;
        });
      },
      hoverColor: Colors.transparent,
      splashColor: activeGlowColor.withOpacity(0.15),
      highlightColor: activeGlowColor.withOpacity(0.08),
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.color,
          gradient: widget.color == null ? backgroundGradient : null,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: activeBorder,
        ),
        child: widget.child,
      ),
    );

    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? -widget.lift : 0.0)
          ..scale(_isHovered ? 1.02 : 1.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: activeShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
            child: current,
          ),
        ),
      ),
    );
  }
}

