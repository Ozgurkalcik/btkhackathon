import 'package:equatable/equatable.dart';

/// Chat BLoC Events
abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

/// Kullanıcı mesaj gönderdi
class ChatMessageSent extends ChatEvent {
  final String message;
  const ChatMessageSent(this.message);
  @override
  List<Object?> get props => [message];
}

/// Chat geçmişi yükle
class ChatHistoryLoaded extends ChatEvent {
  const ChatHistoryLoaded();
}

/// Chat geçmişini temizle
class ChatHistoryCleared extends ChatEvent {
  const ChatHistoryCleared();
}

/// Gemini API key ayarlandı
class ChatApiKeyConfigured extends ChatEvent {
  final String apiKey;
  const ChatApiKeyConfigured(this.apiKey);
  @override
  List<Object?> get props => [apiKey];
}
