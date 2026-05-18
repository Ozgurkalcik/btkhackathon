import 'package:flutter/material.dart';
import '../../../../navigation_helper.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: 'Ahmet Yılmaz');
    _emailCtrl = TextEditingController(text: 'ahmet.yilmaz@email.com');
    _phoneCtrl = TextEditingController(text: '+90 555 123 4567');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // Simulate network request
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kişisel bilgiler başarıyla güncellendi!'), backgroundColor: Colors.green),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: buildCommonAppBar(context: context, title: 'Kişisel Bilgiler', showBackButton: true),
      body: SingleChildScrollView(
        padding: sizes.screenPadding.copyWith(top: sizes.sp(24)),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: sizes.sp(100),
                      height: sizes.sp(100),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? AppColors.surfaceContainerHigh : Colors.grey[300],
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: Icon(Icons.person, size: sizes.sp(50), color: isDark ? AppColors.onSurfaceVariant : Colors.grey[700]),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fotoğraf seçici yakında eklenecek')));
                        },
                        child: Container(
                          padding: EdgeInsets.all(sizes.sp(6)),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.edit, size: sizes.sp(16), color: AppColors.onPrimary),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: sizes.sp(32)),
              _buildInfoField(context, 'Ad Soyad', _nameCtrl, Icons.badge),
              _buildInfoField(context, 'E-posta', _emailCtrl, Icons.email),
              _buildInfoField(context, 'Telefon', _phoneCtrl, Icons.phone),
              SizedBox(height: sizes.sp(32)),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  minimumSize: Size(double.infinity, sizes.sp(50)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Değişiklikleri Kaydet'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoField(BuildContext context, String label, TextEditingController controller, IconData icon) {
    final sizes = AppSizes(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(bottom: sizes.sp(16)),
      child: TextFormField(
        controller: controller,
        validator: (val) => val == null || val.isEmpty ? 'Bu alan boş bırakılamaz' : null,
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: isDark ? AppColors.onSurfaceVariant : Colors.grey[600]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: isDark ? AppColors.surfaceContainer : Colors.white,
        ),
      ),
    );
  }
}
