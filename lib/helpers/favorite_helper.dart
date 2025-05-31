import 'package:shared_preferences/shared_preferences.dart';

class FavoriteHelper {
  static const _key = 'favorite_phones';

  static Future<List<int>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key)?.map((e) => int.parse(e)).toList() ?? [];
  }

  static Future<void> addFavorite(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    if (!favorites.contains(id)) {
      favorites.add(id);
      await prefs.setStringList(_key, favorites.map((e) => e.toString()).toList());
    }
  }

  static Future<void> removeFavorite(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    favorites.remove(id);
    await prefs.setStringList(_key, favorites.map((e) => e.toString()).toList());
  }

  static Future<bool> isFavorite(int id) async {
    final favorites = await getFavorites();
    return favorites.contains(id);
  }
}