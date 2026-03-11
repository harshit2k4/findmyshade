import 'package:hive_flutter/hive_flutter.dart';

// Simple wrapper around a Hive box storing a list of saved shade IDs
class FavouritesBox {
  FavouritesBox._();

  static const _boxName = 'favourites';
  static const _key = 'saved_shade_ids';

  static Future<void> init() async {
    await Hive.openBox<List>(_boxName);
  }

  static Box<List> get _box => Hive.box<List>(_boxName);

  static List<String> getAll() {
    final raw = _box.get(_key);
    return raw == null ? [] : List<String>.from(raw);
  }

  static Future<void> save(List<String> ids) async {
    await _box.put(_key, ids);
  }
}
