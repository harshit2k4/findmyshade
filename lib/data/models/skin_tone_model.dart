import 'package:flutter/material.dart';

class SkinToneModel {
  final String id;
  final String label;
  final String description;
  final Color color;

  const SkinToneModel({
    required this.id,
    required this.label,
    required this.description,
    required this.color,
  });
}

// Indian skin tone palette
const indianSkinTones = [
  SkinToneModel(
    id: 'fair',
    label: 'Fair',
    description: 'Light, cool undertone',
    color: Color(0xFFF5D5B8),
  ),
  SkinToneModel(
    id: 'wheatish_light',
    label: 'Wheatish Light',
    description: 'Warm, golden undertone',
    color: Color(0xFFE8B98A),
  ),
  SkinToneModel(
    id: 'wheatish',
    label: 'Wheatish',
    description: 'Medium, warm undertone',
    color: Color(0xFFD49B6A),
  ),
  SkinToneModel(
    id: 'medium',
    label: 'Medium',
    description: 'Olive, neutral undertone',
    color: Color(0xFFC07D4A),
  ),
  SkinToneModel(
    id: 'dusky',
    label: 'Dusky',
    description: 'Deep, warm undertone',
    color: Color(0xFF9E6035),
  ),
  SkinToneModel(
    id: 'deep',
    label: 'Deep',
    description: 'Rich, deep undertone',
    color: Color(0xFF6B3A1F),
  ),
];
