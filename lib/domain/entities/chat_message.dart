import 'package:equatable/equatable.dart';

/// Chat Mesajı Domain Entity
class ChatMessage extends Equatable {
  final String id;
  final ChatRole role;
  final String content;
  final DateTime timestamp;
  final bool isLoading;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [id, role, content, timestamp];
}

enum ChatRole { user, assistant, system }
