import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_provider.dart';
import '../../theme/app_theme.dart';

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
    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ফোন নম্বর ও পাসওয়ার্ড দিন')),
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
    final isKarigor = widget.role == 'karigor';
    final primaryColor = isKarigor ? AppColors.terracotta : AppColors.slate;

    return Scaffold(
      backgroundColor: AppColors.clayBg,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Text(isKarigor ? 'কারিগর লগইন' : 'সেবা গ্রহণকারী লগইন'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Icon(
              isKarigor ? Icons.construction_rounded : Icons.person_search_rounded,
              size: 72,
              color: primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              isKarigor ? 'কারিগর হিসেবে লগইন' : 'সেবা গ্রহণকারী হিসেবে লগইন',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryColor),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'মোবাইল নম্বর',
                prefixIcon: Icon(Icons.phone),
                hintText: '01XXXXXXXXX',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'পাসওয়ার্ড',
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
            Consumer<AuthProvider>(
              builder: (_, auth, __) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor),
                  onPressed: auth.isLoading ? null : _login,
                  child: auth.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('লগইন করুন',
                          style: TextStyle(fontSize: 16)),
                );
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
              child: Text(
                'পাসওয়ার্ড ভুলে গেছেন?',
                style: TextStyle(color: primaryColor.withValues(alpha: 0.8), fontSize: 13),
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(
                  context, '/register',
                  arguments: widget.role),
              child: Text(
                'নতুন? এখানে নিবন্ধন করুন',
                style: TextStyle(color: primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
