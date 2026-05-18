import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_helper.dart';
import 'services/data_repository.dart';
import 'config/bank_config.dart';
import 'presentation/bloc/settings/settings_cubit.dart';
import 'presentation/bloc/settings/settings_state.dart';
import 'presentation/bloc/auth/auth_cubit.dart';
import 'core/security/secure_storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DataRepository _repo = DataRepository();

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
    return Center(child: Column(children: [
      Container(
        width: s.sp(96), height: s.sp(96), padding: EdgeInsets.all(s.sp(4)),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 4)),
        child: Container(
          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.surfaceContainerHigh),
          child: Icon(Icons.person, color: AppColors.primary, size: s.sp(40)),
        ),
      ),
      SizedBox(height: s.sp(16)),
      Text('Kullanıcı', style: TextStyle(fontSize: s.sp(24), fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.onSurface)),
      SizedBox(height: s.sp(8)),
      Container(
        padding: EdgeInsets.symmetric(horizontal: s.sp(16), vertical: s.sp(6)),
        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(999), border: Border.all(color: AppColors.primary.withOpacity(0.3))),
        child: Text(
          _repo.hasBankConnections ? '${_repo.connectedBankCount} Banka Bağlı' : 'Bağlantı Yok',
          style: TextStyle(fontSize: s.sp(12), color: AppColors.primary, fontWeight: FontWeight.w600),
        ),
      ),
    ]));
  }

  Widget _buildFinancialSummary(AppSizes s) {
    return Row(children: [
      Expanded(child: Container(
        padding: EdgeInsets.all(s.sp(16)),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
          gradient: RadialGradient(center: Alignment.topLeft, radius: 1.4, colors: [AppColors.primary.withOpacity(0.15), Colors.transparent]),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Icon(Icons.account_balance, color: AppColors.primary, size: s.sp(20)),
            Text('BAKİYE', style: TextStyle(fontSize: s.sp(12), color: AppColors.primary, fontWeight: FontWeight.w600)),
          ]),
          SizedBox(height: s.sp(8)),
          Text('Toplam', style: TextStyle(fontSize: s.sp(12), color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.onSurfaceVariant)),
          SizedBox(height: s.sp(4)),
          Text(_repo.hasData ? '₺${_repo.totalBalance.toStringAsFixed(0)}' : '—', style: TextStyle(fontSize: s.sp(22), fontWeight: FontWeight.bold, color: AppColors.primary)),
        ]),
      )),
      SizedBox(width: s.sp(16)),
      Expanded(child: Container(
        padding: EdgeInsets.all(s.sp(16)),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Icon(Icons.insights, color: AppColors.tertiary, size: s.sp(20)),
            Text('İŞLEM', style: TextStyle(fontSize: s.sp(12), color: AppColors.tertiary, fontWeight: FontWeight.w600)),
          ]),
          SizedBox(height: s.sp(8)),
          Text('Toplam', style: TextStyle(fontSize: s.sp(12), color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.onSurfaceVariant)),
          SizedBox(height: s.sp(4)),
          Text('${_repo.transactions.length}', style: TextStyle(fontSize: s.sp(22), fontWeight: FontWeight.bold, color: AppColors.tertiary)),
        ]),
      )),
    ]);
  }

  Widget _buildSectionHeader(String title, AppSizes s) {
    return Padding(padding: EdgeInsets.only(left: s.sp(4)), child: Text(title, style: TextStyle(fontSize: s.sp(12), color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.onSurfaceVariant, fontWeight: FontWeight.w600, letterSpacing: 0.5)));
  }

  Widget _buildBankConnectionsList(AppSizes s) {
    final banks = BankRegistry.banks;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03), borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05))),
      child: Column(children: List.generate(math_min(banks.length, 5), (i) {
        final bank = banks[i];
        final isLast = i == math_min(banks.length, 5) - 1;
        return Container(
          padding: EdgeInsets.all(s.sp(16)),
          decoration: BoxDecoration(border: !isLast ? Border(bottom: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05))) : null),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Container(
                width: s.sp(36), height: s.sp(36),
                decoration: BoxDecoration(color: bank.isReady ? AppColors.primary.withOpacity(0.1) : (isDark ? AppColors.surfaceContainerHighest : Colors.grey.withOpacity(0.2)), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.account_balance, color: bank.isReady ? AppColors.primary : (isDark ? AppColors.onSurfaceVariant : Colors.grey), size: s.sp(18)),
              ),
              SizedBox(width: s.sp(12)),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(bank.shortName, style: TextStyle(fontSize: s.sp(15), color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.onSurface, fontWeight: FontWeight.w500)),
                Text(bank.isReady ? 'Bağlı' : 'API anahtarı bekleniyor', style: TextStyle(fontSize: s.sp(11), color: bank.isReady ? AppColors.primary : (isDark ? AppColors.onSurfaceVariant : Colors.grey))),
              ]),
            ]),
            Container(
              padding: EdgeInsets.symmetric(horizontal: s.sp(10), vertical: s.sp(4)),
              decoration: BoxDecoration(
                color: bank.isReady ? AppColors.primary.withOpacity(0.1) : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: bank.isReady ? AppColors.primary.withOpacity(0.3) : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05))),
              ),
              child: Text(bank.isReady ? 'Aktif' : 'Yapılandır', style: TextStyle(fontSize: s.sp(11), color: bank.isReady ? AppColors.primary : (isDark ? AppColors.onSurfaceVariant : Colors.grey[700]), fontWeight: FontWeight.w600)),
            ),
          ]),
        );
      })),
    );
  }

  Widget _buildAccountSettings(AppSizes s) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03), borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05))),
      child: Column(children: [
        _buildListTile(Icons.person, 'Kişisel Bilgiler', true, s, onTap: () => Navigator.pushNamed(context, '/profile/personal_info')),
        _buildListTile(Icons.payments, 'Ödeme Yöntemleri', true, s, onTap: () => Navigator.pushNamed(context, '/profile/payment_methods')),
        _buildListTile(Icons.shield, 'Güvenlik', true, s, onTap: () => Navigator.pushNamed(context, '/profile/security_settings')),
        _buildGeminiApiTile(s, isDark),
      ]),
    );
  }

  Widget _buildListTile(IconData icon, String title, bool hasDivider, AppSizes s, {required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(s.sp(16)),
        decoration: BoxDecoration(border: hasDivider ? Border(bottom: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05))) : null),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [Icon(icon, color: isDark ? AppColors.onSurfaceVariant : Colors.grey[700], size: s.sp(22)), SizedBox(width: s.sp(16)), Text(title, style: TextStyle(fontSize: s.sp(16), color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.onSurface))]),
          Icon(Icons.chevron_right, color: isDark ? AppColors.onSurfaceVariant : Colors.grey[700], size: s.sp(22)),
        ]),
      ),
    );
  }

  Widget _buildGeminiApiTile(AppSizes s, bool isDark) {
    return InkWell(
      onTap: () => _showGeminiApiDialog(),
      child: Container(
        padding: EdgeInsets.all(s.sp(16)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [Icon(Icons.api, color: isDark ? AppColors.onSurfaceVariant : Colors.grey[700], size: s.sp(22)), SizedBox(width: s.sp(16)), Text('API Ayarları (Gemini)', style: TextStyle(fontSize: s.sp(16), color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.onSurface))]),
          Icon(Icons.chevron_right, color: isDark ? AppColors.onSurfaceVariant : Colors.grey[700], size: s.sp(22)),
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

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Gemini API Anahtarı'),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'API Anahtarınızı girin',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                await SecureStorageService.setGeminiApiKey(controller.text.trim());
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03), borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05))),
      child: Column(children: [
        _buildSwitch(Icons.dark_mode, 'Karanlık Mod', state.themeMode == ThemeMode.dark, AppColors.primary, (v) => context.read<SettingsCubit>().toggleTheme(v), true, s, isDark),
        _buildSwitch(Icons.notifications_active, 'Bildirimler', state.notificationsEnabled, AppColors.surfaceContainerHighest, (v) => context.read<SettingsCubit>().toggleNotifications(v), true, s, isDark),
        _buildSwitch(Icons.psychology, 'AI Öneriler', state.aiInsightsEnabled, AppColors.tertiary, (v) => context.read<SettingsCubit>().toggleAiInsights(v), false, s, isDark),
      ]),
    );
  }

  Widget _buildSwitch(IconData icon, String title, bool value, Color activeColor, ValueChanged<bool> onChanged, bool hasDivider, AppSizes s, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: s.sp(16), vertical: s.sp(12)),
      decoration: BoxDecoration(border: hasDivider ? Border(bottom: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05))) : null),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [Icon(icon, color: isDark ? AppColors.onSurfaceVariant : Colors.grey[700], size: s.sp(22)), SizedBox(width: s.sp(16)), Text(title, style: TextStyle(fontSize: s.sp(16), color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.onSurface))]),
        Switch(value: value, onChanged: onChanged, activeColor: AppColors.onPrimary, activeTrackColor: activeColor == AppColors.surfaceContainerHighest ? (isDark ? AppColors.surfaceContainerHighest : Colors.grey[400]) : activeColor, inactiveThumbColor: isDark ? AppColors.onSurfaceVariant : Colors.grey, inactiveTrackColor: isDark ? AppColors.surfaceContainerHigh : Colors.grey[300]),
      ]),
    );
  }

  Widget _buildLogoutButton(AppSizes s) {
    return SizedBox(
      width: double.infinity, height: s.sp(56),
      child: OutlinedButton(
        onPressed: () {
          // Çıkış yapıldığında AuthCubit durumu Unauthenticated'a çeker,
          // ancak profil ekranındayız. Bu yüzden navigator ile login'e atalım
          // veya AuthCheckScreen ana route'u üzerinden yönlendirme alalım.
          context.read<AuthCubit>().logout();
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        },
        style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.secondary.withOpacity(0.3)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), foregroundColor: AppColors.secondary),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.logout, size: s.sp(20)),
          SizedBox(width: s.sp(8)),
          Text('Çıkış Yap', style: TextStyle(fontSize: s.sp(18), fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  int math_min(int a, int b) => a < b ? a : b;
}