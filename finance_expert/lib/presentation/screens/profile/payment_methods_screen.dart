import 'package:flutter/material.dart';
import '../../../../navigation_helper.dart';

class PaymentCard {
  final String number;
  final String expiry;
  final String bankName;
  final Color bgColor;

  PaymentCard({required this.number, required this.expiry, required this.bankName, required this.bgColor});
}

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<PaymentCard> _cards = [
    PaymentCard(number: '**** **** **** 1234', expiry: '12/26', bankName: 'Garanti BBVA', bgColor: AppColors.primaryContainer),
    PaymentCard(number: '**** **** **** 9876', expiry: '08/25', bankName: 'Akbank', bgColor: AppColors.tertiaryContainer),
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
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: sizes.sp(20),
            right: sizes.sp(20),
            top: sizes.sp(20),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Yeni Kart Ekle', style: TextStyle(fontSize: sizes.sp(20), fontWeight: FontWeight.bold)),
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
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    minimumSize: Size(double.infinity, sizes.sp(50)),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      setState(() {
                        _cards.add(PaymentCard(
                          number: _newCardNumber,
                          expiry: _newExpiry,
                          bankName: _newBankName,
                          bgColor: AppColors.secondaryContainer,
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

    return Scaffold(
      appBar: buildCommonAppBar(context: context, title: 'Ödeme Yöntemleri', showBackButton: true),
      body: ListView(
        padding: sizes.screenPadding.copyWith(top: sizes.sp(24)),
        children: [
          Text('Kayıtlı Kartlarım', style: TextStyle(fontSize: sizes.sp(18), fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
          SizedBox(height: sizes.sp(16)),
          if (_cards.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: sizes.sp(30)),
              child: const Center(child: Text('Henüz kayıtlı kartınız yok.')),
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
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: _buildCreditCard(context, card.number, card.expiry, card.bankName, card.bgColor),
              ),
            );
          }),
          SizedBox(height: sizes.sp(16)),
          OutlinedButton.icon(
            onPressed: () => _showAddCardSheet(context),
            icon: const Icon(Icons.add),
            label: const Text('Yeni Kart Ekle'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: EdgeInsets.symmetric(vertical: sizes.sp(16)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCreditCard(BuildContext context, String number, String expiry, String bankName, Color bgColor) {
    final sizes = AppSizes(context);
    return Container(
      padding: EdgeInsets.all(sizes.sp(20)),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(bankName, style: TextStyle(fontSize: sizes.sp(16), fontWeight: FontWeight.bold, color: Colors.white)),
              Icon(Icons.credit_card, color: Colors.white, size: sizes.sp(28)),
            ],
          ),
          SizedBox(height: sizes.sp(24)),
          Text(number, style: TextStyle(fontSize: sizes.sp(22), letterSpacing: 2, color: Colors.white)),
          SizedBox(height: sizes.sp(16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Son Kullanma', style: TextStyle(fontSize: sizes.sp(12), color: Colors.white70)),
              Text(expiry, style: TextStyle(fontSize: sizes.sp(14), fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          )
        ],
      ),
    );
  }
}
