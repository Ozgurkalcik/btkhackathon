import '../entities/chat_message.dart';

/// Chat Repository Contract (Domain Layer)
abstract class ChatRepository {
  /// Gemini'ye mesaj gönder ve cevap al
  Future<ChatMessage> sendMessage({
    required String message,
    List<ChatMessage>? conversationHistory,
    String? financialContext,
  });

  /// Chat geçmişini kaydet
  Future<void> saveChatHistory(List<ChatMessage> messages);

  /// Chat geçmişini yükle
  Future<List<ChatMessage>> loadChatHistory();

  /// Chat geçmişini temizle
  Future<void> clearChatHistory();
}
