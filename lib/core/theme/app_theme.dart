import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette lifted from Brawl Stars' own menus: deep violet depth, gold for
/// anything you press, and a violet-tinted muted text instead of grey so the
/// whole surface stays inside the game's world.
///
/// Anything that represents a brawler, a rarity or a game mode is NOT coloured
/// from this file — it uses the hex the API reports for that object, so the app
/// never invents a colour the game itself doesn't use.
class AppColors {
  static const Color background = Color(0xFF150A33);
  static const Color surface = Color(0xFF241452);
  static const Color surfaceAlt = Color(0xFF32206B);

  /// Darker lip drawn under pressable things — the game's chunky button look.
  static const Color edge = Color(0xFF130931);

  static const Color primary = Color(0xFFFFC83C);
  static const Color primaryEdge = Color(0xFFD1960E);
  static const Color secondary = Color(0xFF8A5BFF);

  static const Color accentPink = Color(0xFFFE5E72);
  static const Color accentBlue = Color(0xFF3FD2FF);
  static const Color accentGreen = Color(0xFF4BE08B);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFFB3A6DC);
}

/// Shared spacing/shape constants so screens stop each inventing their own.
class AppSizes {
  static const double gutter = 16;
  static const double radius = 18;
  static const double radiusSm = 12;
  static const double buttonLip = 3;
}

class AppTheme {
  /// Display face — the heavy rounded poster type the game uses for names and
  /// numbers. Body stays Nunito: rounded enough to match, readable at 13px.
  static TextStyle display(
    double size, {
    Color color = AppColors.textPrimary,
    double? height,
    double letterSpacing = 0.2,
  }) {
    return GoogleFonts.lilitaOne(
      fontSize: size,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final body = GoogleFonts.nunitoTextTheme(base.textTheme);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        surface: AppColors.background,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        onPrimary: const Color(0xFF2B1A00),
      ),
      textTheme: body.copyWith(
        displayLarge: display(40),
        displayMedium: display(34),
        headlineLarge: display(30),
        headlineMedium: display(25),
        headlineSmall: display(21),
        titleLarge: display(18),
        titleMedium: body.titleMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 15,
        ),
        bodyLarge: body.bodyLarge?.copyWith(
          color: AppColors.textPrimary,
          fontSize: 15,
          height: 1.45,
        ),
        bodyMedium: body.bodyMedium?.copyWith(
          color: AppColors.textMuted,
          fontSize: 13.5,
          height: 1.45,
        ),
        labelLarge: body.labelLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: display(24),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary,
        labelStyle: body.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
        secondaryLabelStyle: body.bodyMedium?.copyWith(
          color: const Color(0xFF2B1A00),
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        showCheckmark: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: body.bodyMedium?.copyWith(color: AppColors.textMuted),
        prefixIconColor: AppColors.textMuted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.22),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.nunito(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: selected ? AppColors.primary : AppColors.textMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.primary : AppColors.textMuted,
          );
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }
}
