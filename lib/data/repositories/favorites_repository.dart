import 'package:nepali_festival_wishes/models/favorite_wish.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritesRepository {
  static const String _favoritesKey = 'favorites_key';
  List<FavoriteWish> _favorites = [];

  FavoritesRepository() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

    _favorites = favoritesJson
        .map((json) => _favoriteFromJson(json))
        .whereType<FavoriteWish>()
        .toList();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson =
        _favorites.map((favorite) => _favoriteToJson(favorite)).toList();

    await prefs.setStringList(_favoritesKey, favoritesJson);
  }

  Future<List<FavoriteWish>> getAllFavorites() async {
    await _loadFavorites();
    return _favorites;
  }

  Future<bool> addFavorite(FavoriteWish favorite) async {
    // Check if already exists
    bool exists = _favorites.any((fav) =>
        fav.festivalId == favorite.festivalId &&
        fav.wishText == favorite.wishText);

    if (exists) return false;

    _favorites.add(favorite);
    await _saveFavorites();
    return true;
  }

  Future<bool> removeFavorite(String id) async {
    final initialLength = _favorites.length;
    _favorites.removeWhere((favorite) => favorite.id == id);

    if (_favorites.length != initialLength) {
      await _saveFavorites();
      return true;
    }

    return false;
  }

  String _favoriteToJson(FavoriteWish favorite) {
    final Map<String, dynamic> data = {
      'id': favorite.id,
      'festivalId': favorite.festivalId,
      'festivalName': favorite.festivalName,
      'wishText': favorite.wishText,
      'isNepali': favorite.isNepali,
      'dateAdded': favorite.dateAdded.toIso8601String(),
    };

    return jsonEncode(data);
  }

  FavoriteWish? _favoriteFromJson(String json) {
    try {
      final Map<String, dynamic> data = jsonDecode(json);

      return FavoriteWish(
        dateAdded: DateTime.parse(data['dateAdded']),
        id: data['id'],
        festivalId: data['festivalId'],
        festivalName: data['festivalName'],
        wishText: data['wishText'],
        isNepali: data['isNepali'],
      );
    } catch (e) {
      return null;
    }
  }
}
