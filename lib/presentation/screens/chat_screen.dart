import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message.dart';
import '../bloc/chat/chat_bloc.dart';
import '../bloc/chat/chat_event.dart';
import '../bloc/chat/chat_state.dart';
import '../../navigation_helper.dart';

/// Gemini AI Chat Ekranı
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<ChatBloc>().add(ChatMessageSent(text));
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes(context);
    return Scaffold(
      appBar: _buildAppBar(sizes),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatLoaded) _scrollToBottom();
        },
        builder: (context, state) {
          if (state is ChatNotConfigured) return _buildApiKeySetup(sizes);
          if (state is ChatLoading) return const Center(child: CircularProgressIndicator());
          if (state is ChatLoaded) return _buildChatBody(state, sizes);
          if (state is ChatError) {
            return _buildChatBody(
            ChatLoaded(messages: state.previousMessages), sizes,
            errorMessage: state.message,
          );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  AppBar _buildAppBar(AppSizes s) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: colorScheme.surface,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: colorScheme.primary, size: s.sp(22)),
        onPressed: () => Navigator.pushReplacementNamed(context, '/'),
      ),
      title: Row(children: [
        Container(
          width: s.sp(36), height: s.sp(36),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.primaryContainer]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.auto_awesome, color: colorScheme.onPrimary, size: s.sp(20)),
        ),
        SizedBox(width: s.sp(12)),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Finance Expert AI', style: TextStyle(fontSize: s.sp(16), fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
          Text('Gemini destekli', style: TextStyle(fontSize: s.sp(11), color: colorScheme.primary)),
        ]),
      ]),
      actions: [
        IconButton(
          icon: Icon(Icons.delete_outline, color: colorScheme.onSurfaceVariant, size: s.sp(22)),
          onPressed: () => context.read<ChatBloc>().add(const ChatHistoryCleared()),
        ),
      ],
    );
  }

  Widget _buildChatBody(ChatLoaded state, AppSizes s, {String? errorMessage}) {
    return Column(children: [
      Expanded(
        child: RepaintBoundary(
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(s.sp(16)),
            itemCount: state.messages.length + (state.isAiTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == state.messages.length && state.isAiTyping) {
                return _buildTypingIndicator(s);
              }
              return _buildMessageBubble(state.messages[index], s);
            },
          ),
        ),
      ),
      if (errorMessage != null) _buildErrorBanner(errorMessage, s),
      _buildInputBar(s),
    ]);
  }

  Widget _buildMessageBubble(ChatMessage message, AppSizes s) {
    final isUser = message.role == ChatRole.user;
    final colorScheme = Theme.of(context).colorScheme;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: s.sp(12),
          left: isUser ? s.sp(48) : 0,
          right: isUser ? 0 : s.sp(48),
        ),
        padding: EdgeInsets.all(s.sp(14)),
        decoration: BoxDecoration(
          color: isUser ? colorScheme.primary.withValues(alpha: 0.15) : colorScheme.surfaceContainer,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(s.sp(16)),
            topRight: Radius.circular(s.sp(16)),
            bottomLeft: isUser ? Radius.circular(s.sp(16)) : Radius.circular(s.sp(4)),
            bottomRight: isUser ? Radius.circular(s.sp(4)) : Radius.circular(s.sp(16)),
          ),
          border: Border.all(
            color: isUser ? colorScheme.primary.withValues(alpha: 0.3) : colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            fontSize: s.sp(14),
            color: colorScheme.onSurface,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(AppSizes s) {
    final colorScheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: s.sp(12), right: s.sp(48)),
        padding: EdgeInsets.all(s.sp(14)),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(s.sp(16)),
          border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.08)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            width: s.sp(20), height: s.sp(20),
            child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
          ),
          SizedBox(width: s.sp(10)),
          Text('AI düşünüyor...', style: TextStyle(fontSize: s.sp(13), color: colorScheme.onSurfaceVariant)),
        ]),
      ),
    );
  }

  Widget _buildInputBar(AppSizes s) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final colorScheme = Theme.of(context).colorScheme;
    return RepaintBoundary(
      child: Container(
        padding: EdgeInsets.only(left: s.sp(16), right: s.sp(8), top: s.sp(12), bottom: s.sp(12) + bottomPadding),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          border: Border(top: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.08))),
        ),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onSubmitted: (_) => _sendMessage(),
              style: TextStyle(fontSize: s.sp(14), color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Mesajınızı yazın...',
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: s.sp(14)),
                filled: true,
                fillColor: colorScheme.surfaceContainerHigh,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                contentPadding: EdgeInsets.symmetric(horizontal: s.sp(16), vertical: s.sp(10)),
              ),
            ),
          ),
          SizedBox(width: s.sp(8)),
          Container(
            decoration: BoxDecoration(shape: BoxShape.circle, color: colorScheme.primary),
            child: IconButton(
              icon: Icon(Icons.send, color: colorScheme.onPrimary, size: s.sp(20)),
              onPressed: _sendMessage,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildErrorBanner(String msg, AppSizes s) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(s.sp(12)),
      margin: EdgeInsets.symmetric(horizontal: s.sp(16)),
      decoration: BoxDecoration(color: colorScheme.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: colorScheme.error.withValues(alpha: 0.3))),
      child: Text(msg, style: TextStyle(fontSize: s.sp(12), color: colorScheme.error)),
    );
  }

  Widget _buildApiKeySetup(AppSizes s) {
    final keyController = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(s.sp(32)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: s.sp(80), height: s.sp(80),
            decoration: BoxDecoration(shape: BoxShape.circle, color: colorScheme.primary.withValues(alpha: 0.1)),
            child: Icon(Icons.key, color: colorScheme.primary, size: s.sp(40)),
          ),
          SizedBox(height: s.sp(24)),
          Text('Gemini API Anahtarı Gerekli', style: TextStyle(fontSize: s.sp(20), fontWeight: FontWeight.bold, color: colorScheme.onSurface), textAlign: TextAlign.center),
          SizedBox(height: s.sp(12)),
          Text('AI asistanı kullanmak için Google AI Studio\'dan API anahtarınızı girin.', style: TextStyle(fontSize: s.sp(14), color: colorScheme.onSurfaceVariant, height: 1.5), textAlign: TextAlign.center),
          SizedBox(height: s.sp(24)),
          TextField(
            controller: keyController, 
            obscureText: true,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'API anahtarınızı yapıştırın...',
              hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.2))),
            ),
          ),
          SizedBox(height: s.sp(16)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              onPressed: () {
                final key = keyController.text.trim();
                if (key.isNotEmpty) {
                  context.read<ChatBloc>().add(ChatApiKeyConfigured(key));
                }
              },
              child: const Text('Kaydet ve Başla'),
            ),
          ),
        ]),
      ),
    );
  }
}
