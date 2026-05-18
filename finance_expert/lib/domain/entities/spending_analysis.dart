import 'package:equatable/equatable.dart';
import '../../core/constants/mcc_codes.dart';

/// Harcama Analizi Domain Entity
///
/// Ham banka verisinden çözümlenmiş, zenginleştirilmiş harcama bilgisi.
class SpendingAnalysis extends Equatable {
  final String id;
  final String rawBankText;
  final String resolvedMerchant;
  final String category;
  final MccSector sector;
  final String? mccCode;
  final double amount;
  final DateTime date;
  final String? city;
  final String bankSource;
  final HealthImpact? healthImpact;
  final String? aiInsight;

  const SpendingAnalysis({
    required this.id,
    required this.rawBankText,
    required this.resolvedMerchant,
    required this.category,
    required this.sector,
    this.mccCode,
    required this.amount,
    required this.date,
    this.city,
    required this.bankSource,
    this.healthImpact,
    this.aiInsight,
  });

  @override
  List<Object?> get props => [id, rawBankText, resolvedMerchant, amount, date];
}

/// Sağlık Etkisi Değerlendirmesi
class HealthImpact {
  final HealthRisk riskLevel;
  final String description;
  final int? estimatedCalories;

  const HealthImpact({
    required this.riskLevel,
    required this.description,
    this.estimatedCalories,
  });
}

enum HealthRisk { low, medium, high }
