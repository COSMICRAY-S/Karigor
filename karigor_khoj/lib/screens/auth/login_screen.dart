import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_provider.dart';
import '../../services/language_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/language_switch_button.dart';

class LoginScreen extends StatefulWidget {
  final String role;
  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final lang = context.read<LanguageProvider>();
    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lang.t('enter_credentials_msg'))),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _phoneController.text,
      _passwordController.text,
      widget.role,
    );

    if (success && mounted) {
      final route =
          widget.role == 'karigor' ? '/karigor-home' : '/seeker-home';
      Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
    } else if (mounted && auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final isKarigor = widget.role == 'karigor';
    final primaryColor = isKarigor ? AppColors.terracotta : AppColors.slate;
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
          isKarigor ? lang.t('karigor_login_title') : lang.t('seeker_login_title'),
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
            Icon(
              isKarigor ? Icons.construction_rounded : Icons.person_search_rounded,
              size: 68,
              color: primaryColor,
            ),
            const SizedBox(height: 14),
            Text(
              isKarigor
                  ? lang.t('karigor_login_heading')
                  : lang.t('seeker_login_heading'),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: primaryColor),
            ),
            const SizedBox(height: 36),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: lang.t('phone_label'),
                prefixIcon: const Icon(Icons.phone),
                hintText: lang.t('phone_hint'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: lang.t('password_label'),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Consumer<AuthProvider>(
              builder: (_, auth, __) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor),
                  onPressed: auth.isLoading ? null : _login,
                  child: auth.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(lang.t('login_btn'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                );
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
              child: Text(
                lang.t('forgot_password_btn'),
                style: TextStyle(color: primaryColor.withValues(alpha: 0.8), fontSize: 13),
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(
                  context, '/register',
                  arguments: widget.role),
              child: Text(
                lang.t('register_prompt'),
                style: TextStyle(color: primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
