import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_router.dart';
import 'app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Configuration de ScreenUtil pour le responsive design
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 13 mini
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Axio',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: _buildDarkTheme(),
          themeMode: ThemeMode.system,
          routerConfig: router,
          builder: (context, child) {
            // Configuration du texte pour s'adapter à l'échelle du système
            final mediaQuery = MediaQuery.of(context);
            final baseScale = mediaQuery.textScaler.scale(1.0);
            final scale = baseScale.clamp(0.8, 1.2);

            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: TextScaler.linear(scale),
                padding: mediaQuery.padding,
                viewPadding: mediaQuery.viewPadding,
              ),
              child: child!,
            );
          },
        );
      },
    );
  }

  // Thème sombre de l'application
  ThemeData _buildDarkTheme() {
    final baseTheme = ThemeData.dark();
    return baseTheme.copyWith(
      colorScheme: ColorScheme.dark(
        primary: AppTheme.primaryColor,
        secondary: AppTheme.secondaryColor,
        surface: const Color(0xFF121212),
        onSurface: Colors.white,
        error: AppTheme.errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            displayLarge: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            displayMedium: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            bodyLarge: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
            bodyMedium: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white70,
            ),
            labelLarge: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
      cardTheme: ThemeData.dark().cardTheme.copyWith(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFF1E1E1E),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
