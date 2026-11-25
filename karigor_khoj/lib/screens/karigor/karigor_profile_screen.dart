import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class KarigorProfileScreen extends StatefulWidget {
  const KarigorProfileScreen({super.key});

  @override
  State<KarigorProfileScreen> createState() => _KarigorProfileScreenState();
}

class _KarigorProfileScreenState extends State<KarigorProfileScreen> {
  final _bioController = TextEditingController();
  String _selectedCategory = 'গ্যাস লাইন';
  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _categories = [
    'গ্যাস লাইন',
    'ইলেকট্রিশিয়ান',
    'প্লাম্বার',
    'কাঠমিস্ত্রি',
    'AC মেরামত',
    'রঙ মিস্ত্রি',
    'দর্জি',
    'গাড়ি মেকানিক',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser == null) return;

    try {
      final profile = await ApiService.getProviderById(auth.currentUser!.id);
      if (profile != null && mounted) {
        setState(() {
          if (_categories.contains(profile.category)) {
            _selectedCategory = profile.category;
          }
          _bioController.text = profile.bio;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser == null) return;

    setState(() => _isSaving = true);
    try {
      final success = await ApiService.updateProfile(
        auth.currentUser!.id,
        category: _selectedCategory,
        bio: _bioController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ প্রোফাইল সফলভাবে সংরক্ষিত হয়েছে'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ সংরক্ষণ ব্যর্থ: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.clayBg,
      appBar: AppBar(
        backgroundColor: AppColors.panel,
        foregroundColor: AppColors.ink,
        elevation: 0,
        title: const Text('আমার প্রোফাইল', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: AppColors.terracotta, strokeWidth: 2))
                : const Text('সংরক্ষণ', style: TextStyle(color: AppColors.terracotta, fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.terracotta))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        gradient: AppColors.terracottaGradient,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        auth.currentUser?.name.isNotEmpty == true ? auth.currentUser!.name.characters.first : 'জ',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      auth.currentUser?.name ?? 'কারিগর',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.ink),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text('সেবার ধরন', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.ink)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _categories.contains(_selectedCategory) ? _selectedCategory : _categories.first,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: AppColors.panel,
                      prefixIcon: Icon(Icons.work_outline, color: AppColors.slate),
                    ),
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text('পরিচিতি / বায়ো', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.ink)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _bioController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: AppColors.panel,
                      hintText: 'আপনার অভিজ্ঞতা ও দক্ষতা সম্পর্কে লিখুন...',
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.terracotta),
                      icon: _isSaving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.save),
                      label: const Text('প্রোফাইল সংরক্ষণ করুন'),
                      onPressed: _isSaving ? null : _saveProfile,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
