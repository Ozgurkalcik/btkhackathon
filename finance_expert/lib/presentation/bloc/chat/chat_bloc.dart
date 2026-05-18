import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../core/security/secure_storage_service.dart';
import '../../../data/datasources/remote/gemini_datasource.dart';
import '../../../domain/entities/chat_message.dart';
import 'chat_event.dart';
import 'chat_state.dart';

/// Chat BLoC — Gemini AI Konuşma Yönetimi
///
/// Kullanıcı mesajlarını alır, Gemini API'ye gönderir,
/// yanıtları yönetir ve chat geçmişini tutar.
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GeminiDatasource _gemini;
  final _uuid = const Uuid();

  ChatBloc({required GeminiDatasource geminiDatasource})
      : _gemini = geminiDatasource,
        super(const ChatInitial()) {
    on<ChatHistoryLoaded>(_onHistoryLoaded);
    on<ChatMessageSent>(_onMessageSent);
    on<ChatHistoryCleared>(_onHistoryCleared);
    on<ChatApiKeyConfigured>(_onApiKeyConfigured);
  }

  /// Chat geçmişini yükle
  Future<void> _onHistoryLoaded(
    ChatHistoryLoaded event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());

    // API key kontrolü
    final isConfigured = await _gemini.isConfigured();
    if (!isConfigured) {
      emit(const ChatNotConfigured());
      return;
    }

    // Hoş geldin mesajı ile başlat
    final welcomeMessage = ChatMessage(
      id: _uuid.v4(),
      role: ChatRole.assistant,
      content:
          'Merhaba! 👋 Ben Finance Expert AI asistanınızım. '
          'Harcamalarınız hakkında sorular sorabilir, bütçe planı oluşturabilir '
          'veya tasarruf önerileri alabilirsiniz.\n\n'
          'Örnek sorular:\n'
          '• "Bu ay neden daha fazla harcadım?"\n'
          '• "Kahve harcamalarımı nasıl azaltırım?"\n'
          '• "Bana aylık bütçe planı öner"',
      timestamp: DateTime.now(),
    );

    emit(ChatLoaded(messages: [welcomeMessage]));
  }

  /// Kullanıcı mesajı gönderdi
  Future<void> _onMessageSent(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    final currentMessages = state is ChatLoaded
        ? (state as ChatLoaded).messages
        : <ChatMessage>[];

    // 1. Kullanıcı mesajını ekle
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      role: ChatRole.user,
      content: event.message,
      timestamp: DateTime.now(),
    );

    final updatedMessages = [...currentMessages, userMessage];
    emit(ChatLoaded(messages: updatedMessages, isAiTyping: true));

    try {
      // 2. Gemini'ye gönder
      final response = await _gemini.sendChatMessage(event.message);

      // 3. AI yanıtını ekle
      final aiMessage = ChatMessage(
        id: _uuid.v4(),
        role: ChatRole.assistant,
        content: response,
        timestamp: DateTime.now(),
      );

      emit(ChatLoaded(
        messages: [...updatedMessages, aiMessage],
        isAiTyping: false,
      ));
    } catch (e) {
      String errorMsg;
      if (e is GeminiNotConfiguredException) {
        errorMsg = 'Gemini API anahtarı ayarlanmamış. Ayarlar bölümünden ekleyin.';
      } else {
        errorMsg = 'Yanıt alınamadı: ${e.toString()}';
      }

      emit(ChatError(
        message: errorMsg,
        previousMessages: updatedMessages,
      ));

      // Hata sonrası mesajları koruyarak tekrar loaded durumuna geç
      emit(ChatLoaded(messages: updatedMessages, isAiTyping: false));
    }
  }

  /// Chat geçmişini temizle
  Future<void> _onHistoryCleared(
    ChatHistoryCleared event,
    Emitter<ChatState> emit,
  ) async {
    _gemini.resetChat();
    add(const ChatHistoryLoaded());
  }

  /// API key yapılandırıldı
  Future<void> _onApiKeyConfigured(
    ChatApiKeyConfigured event,
    Emitter<ChatState> emit,
  ) async {
    await SecureStorageService.setGeminiApiKey(event.apiKey);
    add(const ChatHistoryLoaded());
  }
}
