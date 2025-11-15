import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Configuration des routes de l'application
final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  debugLogDiagnostics: true,
  routes: [
    // Écran de démarrage
    GoRoute(
      path: '/splash',
      name: 'splash',
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const SplashScreen()),
    ),

    // Authentification
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const LoginScreen()),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const RegisterScreen()),
    ),

    // Application principale
    GoRoute(
      path: '/home',
      name: 'home',
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const HomeScreen()),
    ),

    // Paramètres
    GoRoute(
      path: '/settings',
      name: 'settings',
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const SettingsScreen()),
    ),
  ],

  // Gestion des erreurs
  errorPageBuilder: (context, state) => MaterialPage(
    key: state.pageKey,
    child: Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page non trouvée: ${state.uri.path}',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    ),
  ),
);
