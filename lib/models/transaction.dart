import 'package:flutter/material.dart';

/// Finansal işlem veri modeli
class Transaction {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final String bankSource;
  final String? rawDescription;
  final String? resolvedMerchant;
  final TransactionType type;
  final IconData icon;

  // Enriched Pipeline Verileri
  final String? enrichedCity;
  final String? enrichedDistrict;
  final String? naceCode;
  final String? exactLocation;
  final String? fullCompanyName;

  Transaction({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.bankSource,
    this.rawDescription,
    this.resolvedMerchant,
    required this.type,
    this.icon = Icons.receipt_long,
    this.enrichedCity,
    this.enrichedDistrict,
    this.naceCode,
    this.exactLocation,
    this.fullCompanyName,
  });

  /// Tutarı formatlanmış TL string'i olarak döndürür
  String get formattedAmount {
    final prefix = type == TransactionType.expense ? '-' : '+';
    return '$prefix₺${amount.toStringAsFixed(2)}';
  }

  /// JSON'dan oluştur
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String? ?? 'Diğer',
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      bankSource: json['bankSource'] as String? ?? '',
      rawDescription: json['rawDescription'] as String?,
      resolvedMerchant: json['resolvedMerchant'] as String?,
      type: json['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      enrichedCity: json['enrichedCity'] as String?,
      enrichedDistrict: json['enrichedDistrict'] as String?,
      naceCode: json['naceCode'] as String?,
      exactLocation: json['exactLocation'] as String?,
      fullCompanyName: json['fullCompanyName'] as String?,
    );
  }

  /// JSON'a dönüştür
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'bankSource': bankSource,
      'rawDescription': rawDescription,
      'resolvedMerchant': resolvedMerchant,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'enrichedCity': enrichedCity,
      'enrichedDistrict': enrichedDistrict,
      'naceCode': naceCode,
      'exactLocation': exactLocation,
      'fullCompanyName': fullCompanyName,
    };
  }
}

enum TransactionType { income, expense }
