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

  /// Aşama 2: LLM Parsing
  /// Verilen ham metni analiz edip yapılandırılmış JSON çıktısı döndürür.
  Future<Map<String, dynamic>> parseTransactionToJSON(String rawText) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    
    // Gerçek bir Gemini API bağlantısı olsaydı burada System Prompt ile çağrı yapılırdı.
    // Örnek bir mock response döndürüyoruz.
    if (rawText.contains("NIKBEY GIDA")) {
      return {
        "Sirket_Adi": "NIKBEY GIDA",
        "Sube_Kodu": "",
        "Sehir": "MALATYA",
        "Ekstra_Lokasyon_Ipucu": "",
        "Olası_Sektor": "Gıda/Market"
      };
    } else if (rawText.contains("GRATIS")) {
      return {
        "Sirket_Adi": "GRATIS",
        "Sube_Kodu": "MLT",
        "Sehir": "MALATYA",
        "Ekstra_Lokasyon_Ipucu": "P", // "Park" için ipucu
        "Olası_Sektor": "Kozmetik"
      };
    } else {
      return {
        "Sirket_Adi": "BILINMEYEN",
        "Sehir": "BELIRSIZ",
        "Olası_Sektor": "Diğer"
      };
    }
  }

  /// Aşama 4: Konum Çıkarımı (Deduction)
  /// Kullanıcının son işlemlerini baz alarak mantıksal lokasyon eşleştirmesi yapar.
  Future<Map<String, dynamic>> deduceLocationContext(List<String> recentMerchants, String currentMerchant) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (recentMerchants.contains("GRATIS") && currentMerchant == "NIKBEY GIDA") {
      return {
        "exactLocation": "Malatya Park AVM",
        "district": "Yeşilyurt",
        "confidence": 0.95,
        "reasoning": "Önceki alışveriş Gratis (Malatya Park AVM) içinde yapılmış, NIKBEY GIDA muhtemelen AVM içerisinde veya çok yakınında."
      };
    }

    return {
      "exactLocation": "Bilinmiyor",
      "district": "Bilinmiyor",
      "confidence": 0.0,
      "reasoning": "Bağlam bulunamadı."
    };
  }
}
