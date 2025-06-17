import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nepali_festival_wishes/developer/developer_page.dart';
import 'package:nepali_festival_wishes/features/home/home_screen.dart';
import 'package:nepali_festival_wishes/features/festival_details/festival_details_screen.dart';
import 'package:nepali_festival_wishes/features/favorites/favorites_screen.dart';
import 'package:nepali_festival_wishes/features/about/about_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/festival/:id',
        name: 'festival-details',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return FestivalDetailsScreen(festivalId: id);
        },
      ),
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/about',
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/developer',
        name: 'developer',
        builder: (context, state) => const DeveloperPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Oops!',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'The page you are looking for does not exist.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
