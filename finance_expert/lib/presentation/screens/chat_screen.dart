import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/chat_message.dart';
import '../bloc/chat/chat_bloc.dart';
import '../bloc/chat/chat_event.dart';
import '../bloc/chat/chat_state.dart';
import '../../navigation_helper.dart' hide AppColors;

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
          if (state is ChatError) return _buildChatBody(
            ChatLoaded(messages: state.previousMessages), sizes,
            errorMessage: state.message,
          );
          return const SizedBox.shrink();
        },
      ),
    );
  }

  AppBar _buildAppBar(AppSizes s) {
    return AppBar(
      backgroundColor: AppColors.darkBackground,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.financialGreen, size: s.sp(22)),
        onPressed: () => Navigator.pushReplacementNamed(context, '/'),
      ),
      title: Row(children: [
        Container(
          width: s.sp(36), height: s.sp(36),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.financialGreen, AppColors.financialGreenDark]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.auto_awesome, color: AppColors.trustBlue, size: s.sp(20)),
        ),
        SizedBox(width: s.sp(12)),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Finance Expert AI', style: TextStyle(fontSize: s.sp(16), fontWeight: FontWeight.w700, color: AppColors.textDarkPrimary)),
          Text('Gemini destekli', style: TextStyle(fontSize: s.sp(11), color: AppColors.financialGreen)),
        ]),
      ]),
      actions: [
        IconButton(
          icon: Icon(Icons.delete_outline, color: AppColors.textDarkSecondary, size: s.sp(22)),
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
          color: isUser ? AppColors.financialGreen.withValues(alpha: 0.15) : AppColors.darkSurfaceContainer,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(s.sp(16)),
            topRight: Radius.circular(s.sp(16)),
            bottomLeft: isUser ? Radius.circular(s.sp(16)) : Radius.circular(s.sp(4)),
            bottomRight: isUser ? Radius.circular(s.sp(4)) : Radius.circular(s.sp(16)),
          ),
          border: Border.all(
            color: isUser ? AppColors.financialGreen.withValues(alpha: 0.3) : Colors.white10,
          ),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            fontSize: s.sp(14),
            color: AppColors.textDarkPrimary,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(AppSizes s) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: s.sp(12), right: s.sp(48)),
        padding: EdgeInsets.all(s.sp(14)),
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceContainer,
          borderRadius: BorderRadius.circular(s.sp(16)),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            width: s.sp(20), height: s.sp(20),
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.financialGreen),
          ),
          SizedBox(width: s.sp(10)),
          Text('AI düşünüyor...', style: TextStyle(fontSize: s.sp(13), color: AppColors.textDarkSecondary)),
        ]),
      ),
    );
  }

  Widget _buildInputBar(AppSizes s) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    return RepaintBoundary(
      child: Container(
        padding: EdgeInsets.only(left: s.sp(16), right: s.sp(8), top: s.sp(12), bottom: s.sp(12) + bottomPadding),
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceContainer,
          border: const Border(top: BorderSide(color: Colors.white10)),
        ),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onSubmitted: (_) => _sendMessage(),
              style: TextStyle(fontSize: s.sp(14), color: AppColors.textDarkPrimary),
              decoration: InputDecoration(
                hintText: 'Mesajınızı yazın...',
                hintStyle: TextStyle(color: AppColors.textDarkSecondary, fontSize: s.sp(14)),
                filled: true,
                fillColor: AppColors.darkSurfaceHigh,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                contentPadding: EdgeInsets.symmetric(horizontal: s.sp(16), vertical: s.sp(10)),
              ),
            ),
          ),
          SizedBox(width: s.sp(8)),
          Container(
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.financialGreen),
            child: IconButton(
              icon: Icon(Icons.send, color: AppColors.trustBlue, size: s.sp(20)),
              onPressed: _sendMessage,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildErrorBanner(String msg, AppSizes s) {
    return Container(
      padding: EdgeInsets.all(s.sp(12)),
      margin: EdgeInsets.symmetric(horizontal: s.sp(16)),
      decoration: BoxDecoration(color: AppColors.softRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.softRed.withValues(alpha: 0.3))),
      child: Text(msg, style: TextStyle(fontSize: s.sp(12), color: AppColors.softRed)),
    );
  }

  Widget _buildApiKeySetup(AppSizes s) {
    final keyController = TextEditingController();
    return Center(
      child: Padding(
        padding: EdgeInsets.all(s.sp(32)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: s.sp(80), height: s.sp(80),
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.financialGreen.withValues(alpha: 0.1)),
            child: Icon(Icons.key, color: AppColors.financialGreen, size: s.sp(40)),
          ),
          SizedBox(height: s.sp(24)),
          Text('Gemini API Anahtarı Gerekli', style: TextStyle(fontSize: s.sp(20), fontWeight: FontWeight.bold, color: AppColors.textDarkPrimary), textAlign: TextAlign.center),
          SizedBox(height: s.sp(12)),
          Text('AI asistanı kullanmak için Google AI Studio\'dan API anahtarınızı girin.', style: TextStyle(fontSize: s.sp(14), color: AppColors.textDarkSecondary, height: 1.5), textAlign: TextAlign.center),
          SizedBox(height: s.sp(24)),
          TextField(controller: keyController, obscureText: true, decoration: const InputDecoration(hintText: 'API anahtarınızı yapıştırın...')),
          SizedBox(height: s.sp(16)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
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
