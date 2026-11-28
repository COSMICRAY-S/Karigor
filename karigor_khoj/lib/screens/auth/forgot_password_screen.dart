import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/language_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/language_switch_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final lang = context.read<LanguageProvider>();
    final email = _emailController.text.trim();
    final newPassword = _passwordController.text;

    if (email.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lang.t('fill_all_fields'))),
      );
      return;
    }

    if (newPassword.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lang.t('password_min_length'))),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await ApiService.forgotPassword(email, newPassword);
      setState(() => _isLoading = false);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang.t('password_reset_success')),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${lang.t('error')}: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    const primaryColor = AppColors.slate;
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: AppColors.clayBg,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        leadingWidth: canPop ? 134 : 96,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canPop)
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                ),
              if (canPop) const SizedBox(width: 4),
              const LanguageSwitchButton(isDark: true),
            ],
          ),
        ),
        title: Text(
          lang.t('password_recovery_title'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 20),
            tooltip: lang.t('settings'),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            const Icon(
              Icons.lock_reset_rounded,
              size: 76,
              color: primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              lang.t('password_recovery_title'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryColor),
            ),
            const SizedBox(height: 12),
            Text(
              lang.t('recovery_instruction'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: lang.t('email_label'),
                prefixIcon: const Icon(Icons.email),
                hintText: lang.t('email_hint'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: '${lang.t('new_password_label')} (${lang.t('password_min_length')})',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              onPressed: _isLoading ? null : _resetPassword,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(lang.t('reset_password_btn'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                lang.t('back'),
                style: const TextStyle(color: primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
