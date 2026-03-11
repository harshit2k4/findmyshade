import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/brand_model.dart';

class ShadesLoader {
  ShadesLoader._();

  static Future<List<BrandModel>> load() async {
    final raw = await rootBundle.loadString('assets/data/shades.json');
    final list = jsonDecode(raw) as List;
    return list.map((e) => BrandModel.fromJson(e)).toList();
  }
}
