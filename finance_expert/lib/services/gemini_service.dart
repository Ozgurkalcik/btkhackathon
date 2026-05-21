import 'dart:math';

/// Gemini AI'ın uygulamanın arka planındaki analiz motorunu simüle eder.
class GeminiService {
  final Random _random = Random();

  /// Kullanıcının harcamalarını analiz edip öneri sunar.
  Future<String> analyzeExpenses(double totalExpense, Map<String, double> categoryTotals) async {
    await Future.delayed(const Duration(seconds: 1)); // Simüle edilmiş ağ gecikmesi
    
    // Basit mantık simülasyonu
    String highestCategory = '';
    double highestAmount = 0;
    
    categoryTotals.forEach((key, value) {
      if (value > highestAmount) {
        highestAmount = value;
        highestCategory = key;
      }
    });

    if (highestCategory == 'Giyim') {
      return "Bu ay Giyim kategorisinde ₺${highestAmount.toStringAsFixed(0)} harcama görünüyor. Bu, aylık bütçenin büyük bir kısmını oluşturuyor. Gelecek ay bu kategoride tasarruf ederek hedeflerine daha hızlı ulaşabilirsin.";
    } else if (highestCategory == 'Yemek') {
      return "Dışarıdan yemek harcamaların ₺${highestAmount.toStringAsFixed(0)} seviyesinde. Evde yemek hazırlamak hem bütçeni korumanı hem de daha sağlıklı beslenmeni sağlayabilir.";
    } else if (highestCategory == 'Market') {
      return "Market alışverişleri bu ayki en büyük gider kalemin. Alışverişe çıkmadan önce planlı bir liste yapmak bütçeni yönetmeni kolaylaştırabilir.";
    } else {
      return "Harika gidiyorsun. Bütçeni planladığın sınırlar içerisinde yönetiyorsun, tasarruf alışkanlığına devam edebilirsin.";
    }
  }

  /// Neden daha fazla harcadım?
  Future<String> getWhyDidISpendMore() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final responses = [
      "Geçtiğimiz aya göre dışarıda yemek kategorisinde %12'lik bir artış görünüyor. Hafta sonu aktivitelerinin bunda etkisi olabilir.",
      "Bu ay kozmetik harcamalarına planlananın biraz üzerinde bütçe ayırmışsın. Bir sonraki ay bu kategoride daha rahat bir denge kurabilirsin.",
      "Market kategorisindeki fiyat artışları bütçeni etkilemiş görünüyor. Daha uygun alternatifleri değerlendirerek bütçeni koruyabilirsin.",
    ];
    return responses[_random.nextInt(responses.length)];
  }
}
