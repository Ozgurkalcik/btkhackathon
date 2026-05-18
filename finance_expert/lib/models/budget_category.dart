import 'package:flutter/material.dart';

/// Bütçe kategori veri modeli
class BudgetCategory {
  final String id;
  final String name;
  final double limit;
  final double spent;
  final IconData icon;
  final Color color;

  BudgetCategory({
    required this.id,
    required this.name,
    required this.limit,
    required this.spent,
    this.icon = Icons.category,
    this.color = Colors.teal,
  });

  /// Harcama oranı (0.0 - 1.0+)
  double get progress => limit > 0 ? spent / limit : 0.0;

  /// Kalan miktar
  double get remaining => limit - spent;

  /// Bütçe aşıldı mı?
  bool get isOverBudget => spent > limit;

  /// Formatlanmış durum metni
  String get statusText => '₺${spent.toStringAsFixed(0)} / ₺${limit.toStringAsFixed(0)}';

  /// JSON'dan oluştur
  factory BudgetCategory.fromJson(Map<String, dynamic> json) {
    return BudgetCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      limit: (json['limit'] as num).toDouble(),
      spent: (json['spent'] as num).toDouble(),
    );
  }

  /// JSON'a dönüştür
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'limit': limit,
      'spent': spent,
    };
  }
}
