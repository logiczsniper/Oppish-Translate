import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavouritesViewModel extends ChangeNotifier {
  final String _key = "favs";
  List<String> _favourites = [];

  List<String> get favourites => _favourites ?? [];

  bool isFavourite(String test) => favourites.contains(test) ?? false;

  FavouritesViewModel() {
    loadFavourites();
  }

  void loadFavourites() async {
    final preferences = await SharedPreferences.getInstance();
    _favourites = preferences.getStringList(_key);
    if (_favourites == null) preferences.setStringList(_key, []);
    notifyListeners();
  }

  void addFavourite(String favourite) async {
    final preferences = await SharedPreferences.getInstance();
    _favourites.add(favourite);
    preferences.setStringList(_key, _favourites);
    notifyListeners();
  }

  void removeFavourite(String favourite) async {
    final preferences = await SharedPreferences.getInstance();
    _favourites.remove(favourite);
    preferences.setStringList(_key, _favourites);
    notifyListeners();
  }
}
