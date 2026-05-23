import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_helper.dart';
import 'services/data_repository.dart';
import 'config/bank_config.dart';
import 'presentation/bloc/settings/settings_cubit.dart';
import 'presentation/bloc/settings/settings_state.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/security/encrypted_storage.dart';
import 'presentation/bloc/auth/auth_cubit.dart';
import 'core/security/secure_storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DataRepository _repo = DataRepository();
  String _displayName = 'Kullanıcı';

  @override
  void initState() {
    super.initState();
    _loadUserDisplayName();
  }

  void _loadUserDisplayName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _displayName = user.displayName ?? 'Kullanıcı';
      });
      try {
        final String profileKey = 'user_profile_${user.uid}';
        final storedData = await EncryptedStorage.get<String>(
          EncryptedStorage.boxUserProfile,
          profileKey,
        );
        if (storedData != null) {
          final profileMap = Map<String, dynamic>.from(jsonDecode(storedData));
          if (profileMap['name'] != null && profileMap['name'].toString().isNotEmpty) {
            setState(() {
              _displayName = profileMap['name'];
            });
          }
        }
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes(context);
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        return Scaffold(
          appBar: buildCommonAppBar(context: context, title: 'Profil', showBackButton: true, onBackPressed: () => Navigator.pushReplacementNamed(context, '/')),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: sizes.sp(20), vertical: sizes.sp(24)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildProfileOverview(sizes),
              SizedBox(height: sizes.sp(24)),
              _buildFinancialSummary(sizes),
              SizedBox(height: sizes.sp(24)),
              _buildSectionHeader('BANKA BAĞLANTILARI', sizes),
              SizedBox(height: sizes.sp(8)),
              _buildBankConnectionsList(sizes),
              SizedBox(height: sizes.sp(24)),
              _buildSectionHeader('HESAP AYARLARI', sizes),
              SizedBox(height: sizes.sp(8)),
              _buildAccountSettings(sizes),
              SizedBox(height: sizes.sp(24)),
              _buildSectionHeader('UYGULAMA TERCİHLERİ', sizes),
              SizedBox(height: sizes.sp(8)),
              _buildAppPreferences(settingsState, sizes),
              SizedBox(height: sizes.sp(32)),
              _buildLogoutButton(sizes),
            ]),
          ),
          bottomNavigationBar: buildBottomNavBar(context, -1),
        );
      },
    );
  }

  Widget _buildProfileOverview(AppSizes s) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(child: Column(children: [
      Container(
        width: s.sp(96), height: s.sp(96), padding: EdgeInsets.all(s.sp(4)),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: colorScheme.primary, width: 4)),
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.circle, color: colorScheme.surfaceContainerHigh),
          child: Icon(Icons.person, color: colorScheme.primary, size: s.sp(40)),
        ),
      ),
      SizedBox(height: s.sp(16)),
      Text(_displayName, style: TextStyle(fontSize: s.sp(24), fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
      SizedBox(height: s.sp(8)),
      Container(
        padding: EdgeInsets.symmetric(horizontal: s.sp(16), vertical: s.sp(6)),
        decoration: BoxDecoration(color: colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(999), border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3))),
        child: Text(
          _repo.hasBankConnections ? '${_repo.connectedBankCount} Banka Bağlı' : 'Bağlantı Yok',
          style: TextStyle(fontSize: s.sp(12), color: colorScheme.primary, fontWeight: FontWeight.w600),
        ),
      ),
    ]));
  }

  Widget _buildFinancialSummary(AppSizes s) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(children: [
      Expanded(child: Container(
        padding: EdgeInsets.all(s.sp(16)),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.08)),
          gradient: RadialGradient(center: Alignment.topLeft, radius: 1.4, colors: [colorScheme.primary.withValues(alpha: 0.12), Colors.transparent]),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Icon(Icons.account_balance, color: colorScheme.primary, size: s.sp(20)),
            Text('BAKİYE', style: TextStyle(fontSize: s.sp(12), color: colorScheme.primary, fontWeight: FontWeight.w600)),
          ]),
          SizedBox(height: s.sp(8)),
          Text('Toplam', style: TextStyle(fontSize: s.sp(12), color: colorScheme.onSurfaceVariant)),
          SizedBox(height: s.sp(4)),
          Text(_repo.hasData ? '₺${_repo.totalBalance.toStringAsFixed(0)}' : '—', style: TextStyle(fontSize: s.sp(22), fontWeight: FontWeight.bold, color: colorScheme.primary)),
        ]),
      )),
      SizedBox(width: s.sp(16)),
      Expanded(child: Container(
        padding: EdgeInsets.all(s.sp(16)),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.08)),
          gradient: RadialGradient(center: Alignment.topLeft, radius: 1.4, colors: [colorScheme.tertiary.withValues(alpha: 0.12), Colors.transparent]),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Icon(Icons.insights, color: colorScheme.tertiary, size: s.sp(20)),
            Text('İŞLEM', style: TextStyle(fontSize: s.sp(12), color: colorScheme.tertiary, fontWeight: FontWeight.w600)),
          ]),
          SizedBox(height: s.sp(8)),
          Text('Toplam', style: TextStyle(fontSize: s.sp(12), color: colorScheme.onSurfaceVariant)),
          SizedBox(height: s.sp(4)),
          Text('${_repo.transactions.length}', style: TextStyle(fontSize: s.sp(22), fontWeight: FontWeight.bold, color: colorScheme.tertiary)),
        ]),
      )),
    ]);
  }

  Widget _buildSectionHeader(String title, AppSizes s) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(padding: EdgeInsets.only(left: s.sp(4)), child: Text(title, style: TextStyle(fontSize: s.sp(12), color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600, letterSpacing: 0.5)));
  }

  Widget _buildBankConnectionsList(AppSizes s) {
    final banks = BankRegistry.banks;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.08)),
      ),
      child: Column(children: List.generate(_mathMin(banks.length, 5), (i) {
        final bank = banks[i];
        final isLast = i == _mathMin(banks.length, 5) - 1;
        return Container(
          padding: EdgeInsets.all(s.sp(16)),
          decoration: BoxDecoration(border: !isLast ? Border(bottom: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.08))) : null),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Container(
                width: s.sp(36), height: s.sp(36),
                decoration: BoxDecoration(
                  color: bank.isReady ? colorScheme.primary.withValues(alpha: 0.12) : colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.account_balance, color: bank.isReady ? colorScheme.primary : colorScheme.onSurfaceVariant, size: s.sp(18)),
              ),
              SizedBox(width: s.sp(12)),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(bank.shortName, style: TextStyle(fontSize: s.sp(15), color: colorScheme.onSurface, fontWeight: FontWeight.w500)),
                Text(bank.isReady ? 'Bağlı' : 'API anahtarı bekleniyor', style: TextStyle(fontSize: s.sp(11), color: bank.isReady ? colorScheme.primary : colorScheme.onSurfaceVariant)),
              ]),
            ]),
            Container(
              padding: EdgeInsets.symmetric(horizontal: s.sp(10), vertical: s.sp(4)),
              decoration: BoxDecoration(
                color: bank.isReady ? colorScheme.primary.withValues(alpha: 0.12) : colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: bank.isReady ? colorScheme.primary.withValues(alpha: 0.3) : colorScheme.onSurface.withValues(alpha: 0.08)),
              ),
              child: Text(
                bank.isReady ? 'Aktif' : 'Yapılandır',
                style: TextStyle(
                  fontSize: s.sp(11),
                  color: bank.isReady ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ]),
        );
      })),
    );
  }

  Widget _buildAccountSettings(AppSizes s) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.08)),
      ),
      child: Column(children: [
        _buildListTile(Icons.person, 'Kişisel Bilgiler', true, s, onTap: () => Navigator.pushNamed(context, '/profile/personal_info').then((_) => _loadUserDisplayName())),
        _buildListTile(Icons.payments, 'Ödeme Yöntemleri', true, s, onTap: () => Navigator.pushNamed(context, '/profile/payment_methods')),
        _buildListTile(Icons.shield, 'Güvenlik', true, s, onTap: () => Navigator.pushNamed(context, '/profile/security_settings')),
        _buildGeminiApiTile(s),
      ]),
    );
  }

  Widget _buildListTile(IconData icon, String title, bool hasDivider, AppSizes s, {required VoidCallback onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(s.sp(16)),
        decoration: BoxDecoration(border: hasDivider ? Border(bottom: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.08))) : null),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [Icon(icon, color: colorScheme.onSurfaceVariant, size: s.sp(22)), SizedBox(width: s.sp(16)), Text(title, style: TextStyle(fontSize: s.sp(16), color: colorScheme.onSurface))]),
          Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant, size: s.sp(22)),
        ]),
      ),
    );
  }

  Widget _buildGeminiApiTile(AppSizes s) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => _showGeminiApiDialog(),
      child: Container(
        padding: EdgeInsets.all(s.sp(16)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [Icon(Icons.api, color: colorScheme.onSurfaceVariant, size: s.sp(22)), SizedBox(width: s.sp(16)), Text('API Ayarları (Gemini)', style: TextStyle(fontSize: s.sp(16), color: colorScheme.onSurface))]),
          Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant, size: s.sp(22)),
        ]),
      ),
    );
  }

  void _showGeminiApiDialog() async {
    final TextEditingController controller = TextEditingController();
    final currentKey = await SecureStorageService.getGeminiApiKey();
    if (currentKey != null) {
      controller.text = currentKey;
    }
    if (!mounted) return;

    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text('Gemini API Anahtarı', style: TextStyle(color: colorScheme.onSurface)),
          content: RepaintBoundary(
            child: TextField(
              controller: controller,
              obscureText: true,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'API Anahtarınızı girin',
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.2))),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('İptal', style: TextStyle(color: colorScheme.onSurfaceVariant)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              onPressed: () async {
                await SecureStorageService.setGeminiApiKey(controller.text.trim());
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Gemini API anahtarı kaydedildi.')),
                  );
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppPreferences(SettingsState state, AppSizes s) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.08)),
      ),
      child: Column(children: [
        _buildSwitch(Icons.dark_mode, 'Karanlık Mod', state.themeMode == ThemeMode.dark, colorScheme.primary, (v) => context.read<SettingsCubit>().toggleTheme(v), true, s),
        _buildSwitch(Icons.notifications_active, 'Bildirimler', state.notificationsEnabled, colorScheme.secondary, (v) => context.read<SettingsCubit>().toggleNotifications(v), true, s),
        _buildSwitch(Icons.psychology, 'AI Öneriler', state.aiInsightsEnabled, colorScheme.tertiary, (v) => context.read<SettingsCubit>().toggleAiInsights(v), false, s),
      ]),
    );
  }

  Widget _buildSwitch(IconData icon, String title, bool value, Color activeColor, ValueChanged<bool> onChanged, bool hasDivider, AppSizes s) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: s.sp(16), vertical: s.sp(12)),
      decoration: BoxDecoration(border: hasDivider ? Border(bottom: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.08))) : null),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [Icon(icon, color: colorScheme.onSurfaceVariant, size: s.sp(22)), SizedBox(width: s.sp(16)), Text(title, style: TextStyle(fontSize: s.sp(16), color: colorScheme.onSurface))]),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: colorScheme.onPrimary,
          activeTrackColor: activeColor,
        ),
      ]),
    );
  }

  Widget _buildLogoutButton(AppSizes s) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity, height: s.sp(56),
      child: OutlinedButton(
        onPressed: () {
          context.read<AuthCubit>().logout();
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colorScheme.error.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          foregroundColor: colorScheme.error,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.logout, size: s.sp(20)),
          SizedBox(width: s.sp(8)),
          Text('Çıkış Yap', style: TextStyle(fontSize: s.sp(18), fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  int _mathMin(int a, int b) => a < b ? a : b;
}
