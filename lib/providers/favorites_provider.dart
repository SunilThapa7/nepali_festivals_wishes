import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepali_festival_wishes/models/favorite_wish.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Provider for the list of all favorite wishes
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<FavoriteWish>>(
  (ref) => FavoritesNotifier(),
);

/// Provider to check if a specific wish is a favorite
final favoriteWishProvider =
    StateNotifierProvider.family<FavoriteWishNotifier, bool, String>(
  (ref, wishText) => FavoriteWishNotifier(ref, wishText),
);

/// Notifier for managing the list of all favorite wishes
class FavoritesNotifier extends StateNotifier<List<FavoriteWish>> {
  FavoritesNotifier() : super([]) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList('favorites') ?? [];

    state = favoritesJson
        .map((json) => FavoriteWish.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson =
        state.map((favorite) => jsonEncode(favorite.toJson())).toList();

    await prefs.setStringList('favorites', favoritesJson);
  }

  Future<void> addFavorite(FavoriteWish wish) async {
    // Check if the wish already exists by text content to avoid duplicates
    if (!state.any((favorite) => favorite.wishText == wish.wishText)) {
      state = [...state, wish];
      await _saveFavorites();
    }
  }

  Future<void> removeFavorite(String wishText) async {
    state = state.where((favorite) => favorite.wishText != wishText).toList();
    await _saveFavorites();
  }

  bool isFavorite(String wishText) {
    return state.any((favorite) => favorite.wishText == wishText);
  }

  List<FavoriteWish> getFavoritesByFestival(String festivalId) {
    return state
        .where((favorite) => favorite.festivalId == festivalId)
        .toList();
  }
}

/// Notifier for managing a single favorite wish
class FavoriteWishNotifier extends StateNotifier<bool> {
  final StateNotifierProviderRef ref;
  final String wishText;

  FavoriteWishNotifier(this.ref, this.wishText) : super(false) {
    _init();
  }

  void _init() {
    final favorites = ref.read(favoritesProvider);
    state = favorites.any((favorite) => favorite.wishText == wishText);
  }

  Future<void> toggleFavorite(
    String festivalName,
    String festivalId,
    String wishText,
    bool isNepali,
  ) async {
    final favoritesNotifier = ref.read(favoritesProvider.notifier);

    if (state) {
      await favoritesNotifier.removeFavorite(wishText);
      state = false;
    } else {
      final wish = FavoriteWish(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        festivalId: festivalId,
        festivalName: festivalName,
        wishText: wishText,
        isNepali: isNepali,
        dateAdded: DateTime.now(),
      );
      await favoritesNotifier.addFavorite(wish);
      state = true;
    }
  }
}
