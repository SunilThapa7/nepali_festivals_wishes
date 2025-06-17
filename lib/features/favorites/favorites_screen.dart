import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepali_festival_wishes/core/utils/app_colors.dart';
import 'package:nepali_festival_wishes/core/utils/app_constants.dart';
import 'package:nepali_festival_wishes/core/utils/app_theme.dart';
import 'package:nepali_festival_wishes/main.dart';
import 'package:nepali_festival_wishes/models/favorite_wish.dart';
import 'package:nepali_festival_wishes/providers/favorites_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  String _selectedFestival = 'All';
  bool _showNepaliOnly = false;
  bool _showEnglishOnly = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    // Get list of unique festival names for filtering
    final festivalNames = [
      'All',
      ...{...favorites.map((f) => f.festivalName)}
    ];

    // Apply filters
    var filteredFavorites = favorites;

    // Filter by festival
    if (_selectedFestival != 'All') {
      filteredFavorites = filteredFavorites
          .where((f) => f.festivalName == _selectedFestival)
          .toList();
    }

    // Filter by language
    if (_showNepaliOnly) {
      filteredFavorites = filteredFavorites.where((f) => f.isNepali).toList();
    } else if (_showEnglishOnly) {
      filteredFavorites = filteredFavorites.where((f) => !f.isNepali).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredFavorites = filteredFavorites
          .where((f) =>
              f.wishText.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Sort by date, newest first
    filteredFavorites.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Wishes'),
        elevation: 0,
        actions: [
          // Theme toggle button
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
            tooltip: isDarkMode ? 'Light Mode' : 'Dark Mode',
          ),
          // Search button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Filter options
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter by:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),

                // Festival filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: festivalNames.map((festival) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(festival),
                          selected: _selectedFestival == festival,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedFestival = festival;
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 8),

                // Language filter
                Row(
                  children: [
                    FilterChip(
                      label: const Text('Nepali Only'),
                      selected: _showNepaliOnly,
                      onSelected: (selected) {
                        setState(() {
                          _showNepaliOnly = selected;
                          if (selected) {
                            _showEnglishOnly = false;
                          }
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('English Only'),
                      selected: _showEnglishOnly,
                      onSelected: (selected) {
                        setState(() {
                          _showEnglishOnly = selected;
                          if (selected) {
                            _showNepaliOnly = false;
                          }
                        });
                      },
                    ),
                  ],
                ),

                // Search bar (if query exists)
                if (_searchQuery.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Chip(
                          label: Text('Search: $_searchQuery'),
                          onDeleted: () {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Favorites list
          Expanded(
            child: filteredFavorites.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredFavorites.length,
                    itemBuilder: (context, index) {
                      final favorite = filteredFavorites[index];
                      return _buildFavoriteCard(favorite)
                          .animate()
                          .fadeIn(duration: const Duration(milliseconds: 300))
                          .slideY(
                            begin: 0.1,
                            end: 0,
                            curve: Curves.easeOutQuad,
                            duration: const Duration(milliseconds: 300),
                          );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[600]
                : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No favorites found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty ||
                    _selectedFestival != 'All' ||
                    _showNepaliOnly ||
                    _showEnglishOnly
                ? 'Try changing your filters'
                : 'Add wishes to favorites from festival details',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(FavoriteWish favorite) {
    // Use a default color instead of relying on category
    final festivalColor = AppColors.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Festival name
            Row(
              children: [
                Expanded(
                  child: Text(
                    favorite.festivalName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: festivalColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: festivalColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    favorite.isNepali ? 'नेपाली' : 'English',
                    style: TextStyle(
                      color: festivalColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Wish text
            Text(
              favorite.wishText,
              style: TextStyle(
                fontSize: favorite.isNepali ? 18 : 16,
                height: 1.5,
                fontFamily: favorite.isNepali ? 'Poppins' : null,
              ),
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Copy button
                IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copy',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: favorite.wishText))
                        .then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    });
                  },
                ),
                // Share button
                IconButton(
                  icon: const Icon(Icons.share),
                  tooltip: 'Share',
                  onPressed: () {
                    Share.share(
                      '${favorite.wishText}\n\n- ${AppConstants.appName}',
                    );
                  },
                ),
                // Remove from favorites button
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Remove from favorites',
                  onPressed: () {
                    _showRemoveConfirmationDialog(favorite);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Wishes'),
          content: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Enter search text',
              prefixIcon: Icon(Icons.search),
            ),
            onSubmitted: (value) {
              setState(() {
                _searchQuery = value.trim();
              });
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = _searchController.text.trim();
                });
                Navigator.pop(context);
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _showRemoveConfirmationDialog(FavoriteWish favorite) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove from Favorites'),
          content: const Text(
              'Are you sure you want to remove this from favorites?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(favoritesProvider.notifier)
                    .removeFavorite(favorite.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Removed from favorites'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }
}
