import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_provider.dart';

class KarigorProfileScreen extends StatefulWidget {
  const KarigorProfileScreen({super.key});

  @override
  State<KarigorProfileScreen> createState() => _KarigorProfileScreenState();
}

class _KarigorProfileScreenState extends State<KarigorProfileScreen> {
  final _bioController =
      TextEditingController(text: '১০ বছরের বেশি অভিজ্ঞতা।');
  String _selectedCategory = 'প্লাম্বার';

  final List<String> _categories = [
    'প্লাম্বার',
    'ইলেকট্রিশিয়ান',
    'দর্জি',
    'রঙ মিস্ত্রি',
    'AC মেরামত',
    'গাড়ি মেকানিক',
    'ছুতার মিস্ত্রি',
    'রাজমিস্ত্রি',
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE65100),
        title: const Text('আমার প্রোফাইল'),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ প্রোফাইল সংরক্ষিত হয়েছে')),
              );
            },
            child: const Text('সংরক্ষণ',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Photo
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFFE65100).withOpacity(0.1),
                    child: const Icon(Icons.person,
                        size: 60, color: Color(0xFFE65100)),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE65100),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                auth.currentUser?.name ?? 'কারিগর',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),

            // Verification status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_user, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('যাচাই প্রক্রিয়া চলছে',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                            'NID ও সার্টিফিকেট আপলোড করুন যাচাইয়ের জন্য',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('ডকুমেন্ট আপলোড ফিচার শীঘ্রই আসছে')),
                      );
                    },
                    child: const Text('আপলোড'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('সেবার ধরন',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.work),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) =>
                  setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 16),

            const Text('পরিচিতি / বায়ো',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _bioController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'আপনার অভিজ্ঞতা ও দক্ষতা সম্পর্কে লিখুন...',
              ),
            ),
            const SizedBox(height: 16),

            const Text('স্ট্যান্ডার্ড রেট (ঐচ্ছিক)',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '৳ ',
                hintText: 'যেমন: ৫০০ (পরিদর্শন ফি)',
                prefixIcon: Icon(Icons.currency_exchange),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE65100)),
                icon: const Icon(Icons.save),
                label: const Text('প্রোফাইল সংরক্ষণ করুন',
                    style: TextStyle(fontSize: 16)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('✅ প্রোফাইল সংরক্ষিত হয়েছে')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
