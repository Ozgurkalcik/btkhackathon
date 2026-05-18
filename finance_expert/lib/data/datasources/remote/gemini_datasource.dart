import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/security/secure_storage_service.dart';

/// Gemini API Datasource
///
/// Google Gemini ile iletişim kurar. API key SecureStorage'dan okunur.
/// Finansal asistan system prompt'u ile başlatılır.
class GeminiDatasource {
  GenerativeModel? _model;
  ChatSession? _chatSession;

  /// System prompt — Gemini'nin finansal asistan rolünü tanımlar
  static const String _systemPrompt = '''
Sen "Finance Expert" adlı bir AI finansal asistansın. Türkiye'de yaşayan 
kullanıcılara finansal danışmanlık yapıyorsun. Kuralların:

1. Yanıtlarını Türkçe ver.
2. Para birimi olarak TL (₺) kullan.
3. Harcama analizi yaparken kategorize et: Market, Yemek, Giyim, Kozmetik, 
   Ulaşım, Sağlık, Eğitim, Eğlence, Teknoloji, Faturalar, E-ticaret.
4. Sağlık etkisi değerlendirmesi yap (fast food sıklığı, kahve tüketimi vb.).
5. Kişiselleştirilmiş tasarruf önerileri sun.
6. Bütçe planlaması önerilerinde gerçekçi ol.
7. Anomali tespiti yap — beklenmeyen harcama artışlarını işaretle.
8. Yanıtların kısa, net ve aksiyona yönelik olsun.
9. Kullanıcının harcama verilerini analiz ederken gizliliğe dikkat et.
10. Yatırım tavsiyesi verme — sadece harcama optimizasyonu yap.
''';

  /// Gemini modelini başlat
  Future<void> initialize() async {
    final apiKey = await SecureStorageService.getGeminiApiKey();

    if (apiKey == null || apiKey.isEmpty) {
      throw GeminiNotConfiguredException();
    }

    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      systemInstruction: Content.text(_systemPrompt),
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 2048,
        topP: 0.95,
      ),
    );
  }

  /// Tek seferlik mesaj gönder (chat geçmişi olmadan)
  Future<String> generateContent(String prompt) async {
    await _ensureInitialized();

    final response = await _model!.generateContent([Content.text(prompt)]);
    return response.text ?? 'Yanıt alınamadı.';
  }

  /// Chat oturumu başlat veya mevcut oturumda mesaj gönder
  Future<String> sendChatMessage(
    String message, {
    String? financialContext,
  }) async {
    await _ensureInitialized();

    // İlk çağrıda chat session oluştur
    _chatSession ??= _model!.startChat();

    // Finansal bağlam varsa mesaja ekle
    String fullMessage = message;
    if (financialContext != null && financialContext.isNotEmpty) {
      fullMessage = '''
[FİNANSAL BAĞLAM]
$financialContext

[KULLANICI SORUSU]
$message''';
    }

    final response = await _chatSession!.sendMessage(Content.text(fullMessage));
    return response.text ?? 'Yanıt alınamadı.';
  }

  /// Harcama analizi için özel prompt
  Future<String> analyzeSpending({
    required String merchantName,
    required double amount,
    required String category,
    String? rawBankText,
  }) async {
    await _ensureInitialized();

    final prompt = '''
Aşağıdaki harcamayı analiz et:
- Tüccar: $merchantName
- Tutar: ₺${amount.toStringAsFixed(2)}
- Kategori: $category
${rawBankText != null ? '- Ham Banka Metni: $rawBankText' : ''}

Lütfen şunları belirt:
1. Bu harcamanın sağlık etkisi (varsa)
2. Tasarruf önerisi
3. Bu kategorideki harcama trendi hakkında kısa yorum

JSON formatında yanıt ver:
{"healthImpact": "...", "riskLevel": "low|medium|high", "savingTip": "...", "insight": "..."}
''';

    return generateContent(prompt);
  }

  /// Chat oturumunu sıfırla
  void resetChat() {
    _chatSession = null;
  }

  /// Model başlatıldı mı kontrol et
  Future<void> _ensureInitialized() async {
    if (_model == null) {
      await initialize();
    }
  }

  /// API key ayarlanmış mı?
  Future<bool> isConfigured() async {
    return SecureStorageService.hasGeminiApiKey();
  }
}

/// Gemini API key ayarlanmamış hatası
class GeminiNotConfiguredException implements Exception {
  @override
  String toString() =>
      'Gemini API anahtarı ayarlanmamış. Ayarlar > API Anahtarları bölümünden ekleyin.';
}
