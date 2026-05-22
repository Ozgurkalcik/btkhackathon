import '../entities/spending_analysis.dart';

/// Harcama Analizi Repository Contract (Domain Layer)
///
/// Data katmanı bu interface'i implemente eder.
/// Presentation katmanı sadece bu interface'e bağımlıdır.
abstract class SpendingAnalyzerRepository {
  /// Ham banka metnini analiz et ve çözümle
  Future<SpendingAnalysis> analyzeTransaction({
    required String rawText,
    required double amount,
    required DateTime date,
    required String bankSource,
    String? mccCode,
  });

  /// Toplu işlem analizi
  Future<List<SpendingAnalysis>> analyzeTransactionBatch(
    List<Map<String, dynamic>> rawTransactions,
  );

  /// Kategori dağılımını getir
  Future<Map<String, double>> getCategoryBreakdown({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Sağlık etki raporunu getir
  Future<List<SpendingAnalysis>> getHealthImpactReport({
    DateTime? startDate,
    DateTime? endDate,
  });
}
