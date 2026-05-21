import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../navigation_helper.dart';
import '../../../../core/security/encrypted_storage.dart';

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
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _currentUser = FirebaseAuth.instance.currentUser;
    _loadProfileData();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _loadProfileData() async {
    if (_currentUser == null) return;
    
    // Set fallback defaults from Firebase Auth
    _nameCtrl.text = _currentUser?.displayName ?? '';
    _emailCtrl.text = _currentUser?.email ?? '';
    _phoneCtrl.text = _currentUser?.phoneNumber ?? '';

    // Load from secure encrypted Hive storage
    try {
      final String profileKey = 'user_profile_${_currentUser!.uid}';
      final storedData = await EncryptedStorage.get<String>(
        EncryptedStorage.boxUserProfile,
        profileKey,
      );

      if (storedData != null) {
        final profileMap = Map<String, dynamic>.from(jsonDecode(storedData));
        setState(() {
          if (profileMap['name'] != null && profileMap['name'].toString().isNotEmpty) {
            _nameCtrl.text = profileMap['name'];
          }
          if (profileMap['email'] != null && profileMap['email'].toString().isNotEmpty) {
            _emailCtrl.text = profileMap['email'];
          }
          if (profileMap['phoneNumber'] != null && profileMap['phoneNumber'].toString().isNotEmpty) {
            _phoneCtrl.text = profileMap['phoneNumber'];
          }
        });
      }
    } catch (_) {
      // Fallback is already loaded from Firebase Auth
    }
  }

  void _saveChanges() async {
    if (_currentUser == null) return;

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final name = _nameCtrl.text.trim();
        final email = _emailCtrl.text.trim();
        final phone = _phoneCtrl.text.trim();

        // 1. Update Firebase Auth displayName
        await _currentUser!.updateDisplayName(name);

        // 2. Save profile in secure local database
        final String profileKey = 'user_profile_${_currentUser!.uid}';
        final existingData = await EncryptedStorage.get<String>(
          EncryptedStorage.boxUserProfile,
          profileKey,
        );

        Map<String, dynamic> profileMap = {};
        if (existingData != null) {
          try {
            profileMap = Map<String, dynamic>.from(jsonDecode(existingData));
          } catch (_) {}
        }

        profileMap['uid'] = _currentUser!.uid;
        profileMap['name'] = name;
        profileMap['email'] = email;
        profileMap['phoneNumber'] = phone;

        await EncryptedStorage.put<String>(
          EncryptedStorage.boxUserProfile,
          profileKey,
          jsonEncode(profileMap),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kişisel bilgiler başarıyla güncellendi!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Güncelleme sırasında bir hata oluştu: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
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
        child: RepaintBoundary(
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
