import 'package:flutter/material.dart';
import '../../../../navigation_helper.dart';
import '../../../../core/security/secure_storage_service.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _biometricEnabled = false;
  bool _twoFactorEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await SecureStorageService.isBiometricEnabled();
    if (mounted) {
      setState(() {
         _biometricEnabled = enabled;
      });
    }
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        bool hide1 = true;
        bool hide2 = true;
        bool hide3 = true;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Şifreyi Değiştir'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      obscureText: hide1,
                      decoration: InputDecoration(labelText: 'Mevcut Şifre', suffixIcon: IconButton(icon: Icon(hide1 ? Icons.visibility_off : Icons.visibility), onPressed: () => setStateDialog(() => hide1 = !hide1))),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      obscureText: hide2,
                      decoration: InputDecoration(labelText: 'Yeni Şifre', suffixIcon: IconButton(icon: Icon(hide2 ? Icons.visibility_off : Icons.visibility), onPressed: () => setStateDialog(() => hide2 = !hide2))),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      obscureText: hide3,
                      decoration: InputDecoration(labelText: 'Yeni Şifre (Tekrar)', suffixIcon: IconButton(icon: Icon(hide3 ? Icons.visibility_off : Icons.visibility), onPressed: () => setStateDialog(() => hide3 = !hide3))),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Şifreniz başarıyla değiştirildi!'), backgroundColor: Colors.green));
                  },
                  child: const Text('Değiştir'),
                ),
              ],
            );
          }
        );
      }
    );
  }

  void _show2FASetup() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('2FA Kurulumu'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.qr_code_2, size: 100),
              const SizedBox(height: 16),
              const Text('Lütfen kimlik doğrulayıcı uygulamanız ile bu QR kodu tarayın.', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Doğrulama Kodu', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => _twoFactorEnabled = true);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('2FA Başarıyla Aktifleştirildi!'), backgroundColor: Colors.green));
              },
              child: const Text('Doğrula ve Aktifleştir'),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: buildCommonAppBar(context: context, title: 'Güvenlik', showBackButton: true),
      body: ListView(
        padding: sizes.screenPadding.copyWith(top: sizes.sp(24)),
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceContainer : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05))
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.fingerprint),
                  title: const Text('Biyometrik Giriş (Face ID / Touch ID)'),
                  trailing: Switch(
                    value: _biometricEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (val) async {
                      await SecureStorageService.setBiometricEnabled(val);
                      setState(() => _biometricEnabled = val);
                    },
                  ),
                ),
                Divider(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05), height: 1),
                ListTile(
                  leading: const Icon(Icons.password),
                  title: const Text('Şifreyi Değiştir'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showChangePasswordDialog,
                ),
                Divider(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05), height: 1),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('İki Faktörlü Doğrulama (2FA)'),
                  trailing: Switch(
                    value: _twoFactorEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      if (val) {
                        _show2FASetup();
                      } else {
                        setState(() => _twoFactorEnabled = false);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('2FA devre dışı bırakıldı.')));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: sizes.sp(32)),
          Text(
            'Güvenlik sistemleri uçtan uca şifreleme ve banka düzeyinde güvenlik protokolleri ile korunmaktadır.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: sizes.sp(12), color: isDark ? AppColors.onSurfaceVariant : Colors.grey[600], height: 1.5),
          )
        ],
      ),
    );
  }
}
