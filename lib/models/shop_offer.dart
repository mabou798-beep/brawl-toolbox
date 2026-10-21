import 'package:flutter/material.dart';

enum CurrencyType { gems, coins, credits }

class ShopOffer {
  final String title;
  final String subtitle;
  final String imageUrl;
  final int price;
  final CurrencyType currency;
  final String? badge;
  final Color accent;

  const ShopOffer({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.price,
    required this.currency,
    required this.accent,
    this.badge,
  });
}
