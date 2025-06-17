import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepali_festival_wishes/core/utils/app_colors.dart';
import 'package:nepali_festival_wishes/core/utils/app_theme.dart';
import 'package:nepali_festival_wishes/developer/developer_page.dart';
import 'package:nepali_festival_wishes/features/favorites/favorites_screen.dart';
import 'package:nepali_festival_wishes/features/festival_details/festival_details_screen.dart';
import 'package:nepali_festival_wishes/features/home/home_screen.dart';
import 'package:nepali_festival_wishes/features/search/search_screen.dart';
import 'package:nepali_festival_wishes/features/about/about_screen.dart';
import 'package:nepali_festival_wishes/features/category/category_screen.dart';
import 'package:nepali_festival_wishes/features/splash/splash_screen.dart';
import 'package:nepali_festival_wishes/providers/festival_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set status bar color
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const ProviderScope(child: MyApp()));
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Nepali Festival Wishes',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: lightTheme(),
      darkTheme: darkTheme(),
      home: const SplashScreen(),
      routes: {
        '/favorites': (context) => const FavoritesScreen(),
        '/search': (context) => const SearchScreen(),
        '/about': (context) => const AboutScreen(),
        '/home': (context) => const HomeScreen(),
        '/developer': (context) => const DeveloperPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name!.startsWith('/festival/')) {
          final festivalId = settings.name!.substring('/festival/'.length);
          return MaterialPageRoute(
            builder: (context) => FestivalDetailsScreen(festivalId: festivalId),
          );
        }
        if (settings.name == '/category') {
          final category = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => CategoryScreen(category: category),
          );
        }
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        );
      },
    );
  }
}

// Navigation helpers
class AppNavigation {
  static void navigateToHome() {
    navigatorKey.currentState
        ?.pushNamedAndRemoveUntil('/home', (route) => false);
  }

  static void navigateToFestivalDetails(String festivalId) {
    navigatorKey.currentState?.pushNamed('/festival/$festivalId');
  }

  static void navigateToFavorites() {
    navigatorKey.currentState?.pushNamed('/favorites');
  }

  static void navigateToSearch() {
    navigatorKey.currentState?.pushNamed('/search');
  }

  static void navigateToCategory(String category) {
    navigatorKey.currentState?.pushNamed('/category', arguments: category);
  }

  static void navigateToAbout() {
    navigatorKey.currentState?.pushNamed('/about');
  }

  static void navigateToDeveloper() {
    navigatorKey.currentState?.pushNamed('/developer');
  }
}

// Drawer widget for navigation
class AppDrawer extends ConsumerWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 64,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.celebration,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Nepali Festival Wishes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              AppNavigation.navigateToHome();
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            onTap: () {
              Navigator.pop(context);
              AppNavigation.navigateToFavorites();
            },
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Search'),
            onTap: () {
              Navigator.pop(context);
              AppNavigation.navigateToSearch();
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              AppNavigation.navigateToAbout();
            },
          ),
          ListTile(
            leading: const Icon(Icons.developer_mode),
            title: const Text('About Developer'),
            onTap: () {
              Navigator.pop(context);
              AppNavigation.navigateToDeveloper();
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            title: Text(isDarkMode ? 'Light Mode' : 'Dark Mode'),
            onTap: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCategoryButton(
                context,
                ref,
                'Religious',
                Icons.church,
                AppColors.religious,
              ),
              _buildCategoryButton(
                context,
                ref,
                'National',
                Icons.flag,
                AppColors.national,
              ),
              _buildCategoryButton(
                context,
                ref,
                'Cultural',
                Icons.people,
                AppColors.cultural,
              ),
              _buildCategoryButton(
                context,
                ref,
                'Seasonal',
                Icons.nature,
                AppColors.seasonal,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryButton(
    BuildContext context,
    WidgetRef ref,
    String category,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          // Set the selected category
          ref.read(selectedCategoryStringProvider.notifier).state = category;
          // Navigate to category screen
          AppNavigation.navigateToCategory(category);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 16),
              Text(
                category,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
