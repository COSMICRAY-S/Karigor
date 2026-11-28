import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_provider.dart';
import '../../services/language_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/language_switch_button.dart';

class RegisterScreen extends StatefulWidget {
  final String role;
  const RegisterScreen({super.key, required this.role});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final lang = context.read<LanguageProvider>();
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lang.t('fill_all_fields'))),
      );
      return;
    }

    if (_passwordController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lang.t('password_min_length'))),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      _nameController.text,
      _phoneController.text,
      _emailController.text.trim(),
      _passwordController.text,
      widget.role,
    );

    if (success && mounted) {
      final route =
          widget.role == 'karigor' ? '/karigor-home' : '/seeker-home';
      Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
    } else if (mounted && auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${lang.t('error')}: ${auth.error.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
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
          lang.t('register_title'),
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
            const SizedBox(height: 20),
            Text(
              isKarigor
                  ? lang.t('karigor_reg_heading')
                  : lang.t('seeker_reg_heading'),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor),
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: lang.t('full_name_label'),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
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
                labelText: '${lang.t('password_label')} (${lang.t('password_min_length')})',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Consumer<AuthProvider>(
              builder: (_, auth, __) {
                return ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  onPressed: auth.isLoading ? null : _register,
                  child: auth.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(lang.t('register_btn'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                );
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(
                  context, '/login',
                  arguments: widget.role),
              child: Text(
                lang.t('already_have_account'),
                style: TextStyle(color: primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
