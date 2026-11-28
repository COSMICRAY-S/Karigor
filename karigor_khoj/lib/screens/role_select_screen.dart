import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/language_provider.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../widgets/language_switch_button.dart';

class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  String _selectedRole = 'seeker'; // 'seeker' or 'karigor'
  final _emailPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final input = _emailPhoneController.text.trim();
    final pass = _passwordController.text.trim();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final auth = context.read<AuthProvider>();

    // If user provided input, attempt real backend login
    if (input.isNotEmpty && pass.isNotEmpty) {
      try {
        final success = await auth.login(input, pass, _selectedRole);
        if (success) {
          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              _selectedRole == 'karigor' ? '/karigor-home' : '/seeker-home',
            );
          }
          return;
        }
      } catch (e) {
        // Backend returned an error, check if fallback demo login
      }
    }

    // Prototype / Demo Login:
    // If backend is unreachable or user enters any credentials or demo entry
    await Future.delayed(const Duration(milliseconds: 350));

    // Save demo user to auth provider
    auth.login(input, pass, _selectedRole).catchError((_) => false);

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pushReplacementNamed(
        context,
        _selectedRole == 'karigor' ? '/karigor-home' : '/seeker-home',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.roleScreenGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
            child: Column(
              children: [
                // Top Header: Language Switch in Top-Left Corner
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const LanguageSwitchButton(isDark: true),
                    IconButton(
                      icon: Icon(Icons.settings_outlined, color: Colors.white.withValues(alpha: 0.8), size: 22),
                      tooltip: lang.t('settings'),
                      onPressed: () => Navigator.pushNamed(context, '/settings'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Brand Mark
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    gradient: AppColors.brassGradient,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: AppTheme.liftShadow,
                  ),
                  alignment: Alignment.center,
                  child: const Text('🛠️', style: TextStyle(fontSize: 34)),
                ),
                const SizedBox(height: 14),
                Text(
                  lang.t('app_name'),
                  style: const TextStyle(
                    fontFamily: 'Baloo Da 2',
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lang.t('tagline'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 28),

                // Role Cards
                _buildRoleCard(
                  roleKey: 'seeker',
                  iconText: '🔍',
                  iconGradient: AppColors.brassGradient,
                  title: lang.t('seeker_card_title'),
                  subtitle: lang.t('seeker_card_subtitle'),
                  selectedColor: AppColors.brass,
                ),
                const SizedBox(height: 14),
                _buildRoleCard(
                  roleKey: 'karigor',
                  iconText: '🔧',
                  iconGradient: AppColors.terracottaGradient,
                  title: lang.t('karigor_card_title'),
                  subtitle: lang.t('karigor_card_subtitle'),
                  selectedColor: AppColors.terracotta,
                ),

                const SizedBox(height: 32),

                // Auth Block
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: TextField(
                    controller: _emailPhoneController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      icon: Icon(Icons.mail_outline, color: Colors.white.withValues(alpha: 0.6), size: 18),
                      hintText: lang.t('email_phone_hint'),
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 13.5),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      fillColor: Colors.transparent,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      icon: Icon(Icons.lock_outline, color: Colors.white.withValues(alpha: 0.6), size: 18),
                      hintText: lang.t('password_hint'),
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 13.5),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      fillColor: Colors.transparent,
                    ),
                  ),
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(_errorMessage!, style: const TextStyle(color: Colors.orangeAccent, fontSize: 12)),
                ],

                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.terracotta,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          lang.t('sign_in_btn'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 10),
                Text(
                  lang.t('prototype_note'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.45)),
                ),

                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register', arguments: _selectedRole);
                      },
                      child: Text(
                        lang.t('create_account_btn'),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Text(' • ', style: TextStyle(color: Colors.white.withValues(alpha: 0.4))),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgot-password');
                      },
                      child: Text(
                        lang.t('forgot_password_btn'),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String roleKey,
    required String iconText,
    required LinearGradient iconGradient,
    required String title,
    required String subtitle,
    required Color selectedColor,
  }) {
    final isSelected = _selectedRole == roleKey;

    return InkWell(
      onTap: () => setState(() => _selectedRole = roleKey),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? selectedColor : Colors.white.withValues(alpha: 0.14),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedColor.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: iconGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(iconText, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Baloo Da 2',
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.white.withValues(alpha: 0.65),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.4),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
