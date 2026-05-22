import 'package:flutter/material.dart';
import '../../../../navigation_helper.dart';

class PaymentCard {
  final String number;
  final String expiry;
  final String bankName;
  final int colorIndex;

  PaymentCard({
    required this.number,
    required this.expiry,
    required this.bankName,
    required this.colorIndex,
  });
}

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<PaymentCard> _cards = [
    PaymentCard(number: '**** **** **** 1234', expiry: '12/26', bankName: 'Garanti BBVA', colorIndex: 0),
    PaymentCard(number: '**** **** **** 9876', expiry: '08/25', bankName: 'Akbank', colorIndex: 1),
  ];

  final _formKey = GlobalKey<FormState>();
  String _newBankName = '';
  String _newCardNumber = '';
  String _newExpiry = '';

  void _showAddCardSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final sizes = AppSizes(context);
        final colorScheme = Theme.of(context).colorScheme;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(ctx).bottom,
            left: sizes.sp(20),
            right: sizes.sp(20),
            top: sizes.sp(20),
          ),
          child: RepaintBoundary(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Yeni Kart Ekle',
                    style: TextStyle(
                      fontSize: sizes.sp(20),
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: sizes.sp(20)),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Banka Adı', border: OutlineInputBorder()),
                    validator: (val) => val == null || val.isEmpty ? 'Gerekli' : null,
                    onSaved: (val) => _newBankName = val!,
                  ),
                  SizedBox(height: sizes.sp(16)),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Kart Numarası', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (val) => val == null || val.length < 16 ? 'Geçersiz kart numarası' : null,
                    onSaved: (val) {
                      final str = val ?? '';
                      final last4 = str.length > 4 ? str.substring(str.length - 4) : str;
                      _newCardNumber = '**** **** **** $last4';
                    },
                  ),
                  SizedBox(height: sizes.sp(16)),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Son Kullanma (MM/YY)', border: OutlineInputBorder()),
                    validator: (val) => val == null || val.isEmpty ? 'Gerekli' : null,
                    onSaved: (val) => _newExpiry = val!,
                  ),
                  SizedBox(height: sizes.sp(24)),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      minimumSize: Size(double.infinity, sizes.sp(50)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        setState(() {
                          _cards.add(PaymentCard(
                            number: _newCardNumber,
                            expiry: _newExpiry,
                            bankName: _newBankName,
                            colorIndex: 2,
                          ));
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kart başarıyla eklendi!')));
                      }
                    },
                    child: const Text('Kaydet'),
                  ),
                  SizedBox(height: sizes.sp(20)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _removeCard(int index) {
    setState(() {
      _cards.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kart silindi.')));
  }

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: buildCommonAppBar(context: context, title: 'Ödeme Yöntemleri', showBackButton: true),
      body: ListView(
        padding: sizes.screenPadding.copyWith(top: sizes.sp(24)),
        children: [
          Text(
            'Kayıtlı Kartlarım',
            style: TextStyle(
              fontSize: sizes.sp(18),
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: sizes.sp(16)),
          if (_cards.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: sizes.sp(30)),
              child: Center(
                child: Text(
                  'Henüz kayıtlı kartınız yok.',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          ..._cards.asMap().entries.map((entry) {
            final idx = entry.key;
            final card = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: sizes.sp(16)),
              child: Dismissible(
                key: ValueKey(card),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => _removeCard(idx),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: sizes.sp(20)),
                  decoration: BoxDecoration(color: colorScheme.error, borderRadius: BorderRadius.circular(16)),
                  child: Icon(Icons.delete, color: colorScheme.onError),
                ),
                child: _buildCreditCard(context, card),
              ),
            );
          }),
          SizedBox(height: sizes.sp(16)),
          OutlinedButton.icon(
            onPressed: () => _showAddCardSheet(context),
            icon: const Icon(Icons.add),
            label: const Text('Yeni Kart Ekle'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.primary),
              padding: EdgeInsets.symmetric(vertical: sizes.sp(16)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCreditCard(BuildContext context, PaymentCard card) {
    final sizes = AppSizes(context);
    final colorScheme = Theme.of(context).colorScheme;

    // Resolve M3 container and text colors dynamically
    Color cardBgColor;
    Color cardTextColor;

    switch (card.colorIndex) {
      case 0:
        cardBgColor = colorScheme.primaryContainer;
        cardTextColor = colorScheme.onPrimaryContainer;
        break;
      case 1:
        cardBgColor = colorScheme.tertiaryContainer;
        cardTextColor = colorScheme.onTertiaryContainer;
        break;
      case 2:
      default:
        cardBgColor = colorScheme.secondaryContainer;
        cardTextColor = colorScheme.onSecondaryContainer;
        break;
    }

    return Container(
      padding: EdgeInsets.all(sizes.sp(20)),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                card.bankName,
                style: TextStyle(
                  fontSize: sizes.sp(16),
                  fontWeight: FontWeight.bold,
                  color: cardTextColor,
                ),
              ),
              Icon(Icons.credit_card, color: cardTextColor, size: sizes.sp(28)),
            ],
          ),
          SizedBox(height: sizes.sp(24)),
          Text(
            card.number,
            style: TextStyle(
              fontSize: sizes.sp(22),
              letterSpacing: 2,
              color: cardTextColor,
            ),
          ),
          SizedBox(height: sizes.sp(16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Son Kullanma',
                style: TextStyle(
                  fontSize: sizes.sp(12),
                  color: cardTextColor.withOpacity(0.7),
                ),
              ),
              Text(
                card.expiry,
                style: TextStyle(
                  fontSize: sizes.sp(14),
                  fontWeight: FontWeight.bold,
                  color: cardTextColor,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
