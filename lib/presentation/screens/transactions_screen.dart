import 'package:flutter/material.dart';
import '../../navigation_helper.dart';
import '../../services/bank_api_mock_service.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final BankApiMockService _bankService = BankApiMockService();
  List<MockTransaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _transactions = _bankService.fetchRecentTransactions(20);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = getSelectedIndexFromRoute(context);
    final sizes = AppSizes(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: buildCommonAppBar(context: context, title: 'Harcamalar'),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: sizes.sp(20),
          right: sizes.sp(20),
          top: sizes.sp(16),
          bottom: sizes.sp(120),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInsightsBanner(sizes),
            SizedBox(height: sizes.sp(24)),
            Text(
              'Tüm İşlemler',
              style: TextStyle(
                fontSize: sizes.sp(18),
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: sizes.sp(16)),
            _buildTransactionsList(sizes),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(context, selectedIndex),
    );
  }

  Widget _buildInsightsBanner(AppSizes sizes) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(sizes.sp(16)),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: colorScheme.primary, size: sizes.sp(24)),
          SizedBox(width: sizes.sp(12)),
          Expanded(
            child: Text(
              'İşlemleriniz TOBB veritabanı eşleşmeleriyle otomatik kategorize edilmektedir.',
              style: TextStyle(
                fontSize: sizes.sp(13),
                color: colorScheme.primary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(AppSizes sizes) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: _transactions.map((txn) => Padding(
        padding: EdgeInsets.only(bottom: sizes.sp(12)),
        child: Container(
          padding: EdgeInsets.all(sizes.sp(16)),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.onSurface.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: sizes.sp(48),
                height: sizes.sp(48),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getCategoryIcon(txn.category), color: colorScheme.onSurfaceVariant, size: sizes.sp(24)),
              ),
              SizedBox(width: sizes.sp(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      txn.title,
                      style: TextStyle(fontSize: sizes.sp(15), color: colorScheme.onSurface, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: sizes.sp(4)),
                    Text(
                      txn.category,
                      style: TextStyle(fontSize: sizes.sp(13), color: colorScheme.primary),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    txn.formattedAmount,
                    style: TextStyle(
                      fontSize: sizes.sp(16),
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: sizes.sp(4)),
                  Text(
                    '${txn.date.day}/${txn.date.month}/${txn.date.year}',
                    style: TextStyle(fontSize: sizes.sp(11), color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Giyim': return Icons.checkroom;
      case 'Market': return Icons.shopping_cart;
      case 'İçecek': return Icons.local_cafe;
      case 'Yemek': return Icons.restaurant;
      case 'Kozmetik': return Icons.face_retouching_natural;
      case 'Sağlık': return Icons.local_hospital;
      default: return Icons.receipt;
    }
  }
}
