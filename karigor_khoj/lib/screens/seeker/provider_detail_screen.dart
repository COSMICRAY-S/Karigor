import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/provider_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/request_job_modal.dart';
import 'karigor_direct_chat_screen.dart';

class ProviderDetailScreen extends StatefulWidget {
  final int providerId;
  const ProviderDetailScreen({super.key, required this.providerId});

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> {
  ProviderModel? _provider;
  List<dynamic> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final provider = await ApiService.getProviderById(widget.providerId);
      final reviews = await ApiService.getProviderReviews(widget.providerId);
      if (mounted) {
        setState(() {
          _provider = provider;
          _reviews = reviews;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.clayBg,
        body: Center(child: CircularProgressIndicator(color: AppColors.terracotta)),
      );
    }

    final p = _provider;
    if (p == null) {
      return Scaffold(
        backgroundColor: AppColors.clayBg,
        appBar: AppBar(title: const Text('তথ্য পাওয়া যায়নি')),
        body: const Center(child: Text('এই কারিগরের তথ্য পাওয়া যায়নি')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.clayBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.slate,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.slateGradient,
                ),
                child: Center(
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: AppColors.brassGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      p.initial,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (p.isOnline ? AppColors.success : AppColors.offline).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: p.isOnline ? AppColors.success : AppColors.offline),
                        ),
                        child: Text(
                          p.isOnline ? '🟢 অনলাইন' : '⚪ অফলাইন',
                          style: TextStyle(
                            color: p.isOnline ? AppColors.success : AppColors.inkSoft,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (p.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blue),
                          ),
                          child: const Text('✓ যাচাইকৃত', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.brassDark, size: 20),
                          const SizedBox(width: 4),
                          Text('${p.rating} (${p.reviewCount} রিভিউ)',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.ink)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.work_outline, 'পেশা', p.category),
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.phone_outlined, 'ফোন', p.phone.isNotEmpty ? p.phone : '017XXXXXXXX'),
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.location_on_outlined, 'দূরত্ব', '${p.distance.toStringAsFixed(1)} কিমি দূরে'),
                  const Divider(height: 32, color: AppColors.line),

                  const Text('পরিচিতি', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.ink)),
                  const SizedBox(height: 8),
                  Text(
                    p.bio.isNotEmpty ? p.bio : 'অভিজ্ঞ ও দক্ষ পেশাদার কারিগর। আন্তরিকতার সাথে কাজ সম্পন্ন করা হয়।',
                    style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.inkSoft),
                  ),
                  const SizedBox(height: 24),

                  const Text('গ্রাহক রিভিউ', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.ink)),
                  const SizedBox(height: 12),
                  if (_reviews.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.panel,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: const Text(
                        'খুব ভালো ও দ্রুত কাজ সম্পন্ন করে দিয়েছেন। খুবই সন্তুষ্ট!',
                        style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
                      ),
                    )
                  else
                    ..._reviews.map((r) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.panel,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(r['seeker_name']?.toString() ?? 'গ্রাহক', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                                  Text('⭐ ${r['rating']}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.brassDark)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(r['comment']?.toString() ?? '', style: const TextStyle(fontSize: 12.5, color: AppColors.inkSoft)),
                            ],
                          ),
                        )),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.panel,
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('চ্যাট'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.slate,
                  side: const BorderSide(color: AppColors.line),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => KarigorDirectChatScreen(karigor: p)),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send_rounded),
                label: const Text('অনুরোধ পাঠান'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.terracotta),
                onPressed: () => RequestJobModal.show(context, karigor: p),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.slate),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(color: AppColors.inkSoft, fontSize: 13)),
        Expanded(
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink, fontSize: 13.5)),
        ),
      ],
    );
  }
}
