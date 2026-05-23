import 'package:flutter/material.dart';
import '../../navigation_helper.dart';
import '../../services/gemini_service.dart';
import '../../services/bank_api_mock_service.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final GeminiService _geminiService = GeminiService();
  final BankApiMockService _bankService = BankApiMockService();
  
  bool _isLoading = true;
  String _insight = "";
  final List<Map<String, dynamic>> _chatHistory = [];
  final TextEditingController _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialInsight();
  }

  Future<void> _loadInitialInsight() async {
    // Generate some mock totals
    final txns = _bankService.fetchRecentTransactions(50);
    double total = 0;
    Map<String, double> categories = {};
    for (var txn in txns) {
      total += txn.amount;
      categories[txn.category] = (categories[txn.category] ?? 0) + txn.amount;
    }

    final response = await _geminiService.analyzeExpenses(total, categories);
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _insight = response;
        _chatHistory.add({"sender": "ai", "message": "Merhaba! Ben senin finansal asistanın Gemini. Bu ayki harcamalarını inceledim:\n\n$_insight\n\nBaşka ne sormak istersin?"});
      });
    }
  }

  void _sendMessage() {
    if (_chatController.text.trim().isEmpty) return;
    
    final userMsg = _chatController.text.trim();
    setState(() {
      _chatHistory.add({"sender": "user", "message": userMsg});
      _chatController.clear();
      _isLoading = true;
    });

    // Mock response
    Future.delayed(const Duration(seconds: 1), () async {
      final aiMsg = await _geminiService.getWhyDidISpendMore();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _chatHistory.add({"sender": "ai", "message": aiMsg});
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = getSelectedIndexFromRoute(context);
    final sizes = AppSizes(context);

    return Scaffold(
      appBar: buildCommonAppBar(context: context, title: 'AI Asistan'),
      body: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              child: ListView.builder(
                padding: EdgeInsets.all(sizes.sp(16)),
                itemCount: _chatHistory.length,
                itemBuilder: (context, index) {
                  final msg = _chatHistory[index];
                  final isAi = msg['sender'] == 'ai';
                  return _buildChatBubble(msg['message'], isAi, sizes);
                },
              ),
            ),
          ),
          if (_isLoading && _chatHistory.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(sizes.sp(16)),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: CircularProgressIndicator(),
              ),
            ),
          _buildChatInput(sizes),
          SizedBox(height: sizes.sp(90)), // Bottom nav padding
        ],
      ),
      bottomSheet: Container(
        height: 0, // Prevent overlapping with bottom nav
      ),
      bottomNavigationBar: buildBottomNavBar(context, selectedIndex),
    );
  }

  Widget _buildChatBubble(String text, bool isAi, AppSizes sizes) {
    final colorScheme = Theme.of(context).colorScheme;
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(bottom: sizes.sp(16)),
        padding: EdgeInsets.all(sizes.sp(16)),
        constraints: BoxConstraints(maxWidth: sizes.hp(0.75)),
        decoration: BoxDecoration(
          color: isAi ? colorScheme.surfaceContainerHigh : colorScheme.primary.withValues(alpha: 0.18),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isAi ? 0 : 16),
            bottomRight: Radius.circular(isAi ? 16 : 0),
          ),
          border: Border.all(
            color: isAi ? colorScheme.onSurface.withValues(alpha: 0.06) : colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: sizes.sp(14),
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildChatInput(AppSizes sizes) {
    final colorScheme = Theme.of(context).colorScheme;
    return RepaintBoundary(
      child: Container(
        padding: EdgeInsets.all(sizes.sp(16)),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          border: Border(top: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.06))),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: '"Neden çok harcadım?"',
                    hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: sizes.sp(20), vertical: sizes.sp(14)),
                  ),
                ),
              ),
              SizedBox(width: sizes.sp(12)),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.send, color: colorScheme.onPrimary),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
