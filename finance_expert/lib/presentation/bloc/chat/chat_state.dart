import 'package:equatable/equatable.dart';
import '../../../domain/entities/chat_message.dart';

/// Chat BLoC States
abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

/// Başlangıç durumu
class ChatInitial extends ChatState {
  const ChatInitial();
}

/// Chat geçmişi yükleniyor
class ChatLoading extends ChatState {
  const ChatLoading();
}

/// Mesajlar hazır
class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final bool isAiTyping;

  const ChatLoaded({
    required this.messages,
    this.isAiTyping = false,
  });

  ChatLoaded copyWith({
    List<ChatMessage>? messages,
    bool? isAiTyping,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isAiTyping: isAiTyping ?? this.isAiTyping,
    );
  }

  @override
  List<Object?> get props => [messages, isAiTyping];
}

/// Hata durumu
class ChatError extends ChatState {
  final String message;
  final List<ChatMessage> previousMessages;

  const ChatError({
    required this.message,
    this.previousMessages = const [],
  });

  @override
  List<Object?> get props => [message, previousMessages];
}

/// API key yapılandırılmamış
class ChatNotConfigured extends ChatState {
  const ChatNotConfigured();
}
