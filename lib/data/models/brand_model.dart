import 'package:flutter/material.dart';

class ShadeModel {
  final String id;
  final String name;
  final Color color;
  final String finish; // matte | satin | gloss

  const ShadeModel({
    required this.id,
    required this.name,
    required this.color,
    required this.finish,
  });

  factory ShadeModel.fromJson(Map<String, dynamic> j) => ShadeModel(
    id: j['id'],
    name: j['name'],
    color: _hexToColor(j['hex']),
    finish: j['finish'],
  );

  static Color _hexToColor(String hex) {
    final clean = hex.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }
}

class BrandModel {
  final String id;
  final String name;
  final String type;
  final List<ShadeModel> shades;

  const BrandModel({
    required this.id,
    required this.name,
    required this.type,
    required this.shades,
  });

  factory BrandModel.fromJson(Map<String, dynamic> j) => BrandModel(
    id: j['id'],
    name: j['name'],
    type: j['type'],
    shades: (j['shades'] as List).map((s) => ShadeModel.fromJson(s)).toList(),
  );
}
