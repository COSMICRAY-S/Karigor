import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_provider.dart';
import '../../models/provider_model.dart';

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
      setState(() {
        _provider = provider;
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ত্রুটি: তথ্য লোড করা যায়নি। ($e)'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _sendJobRequest() {
    final auth = context.read<AuthProvider>();
    final descController = TextEditingController();
    final locController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('কাজের অনুরোধ পাঠান'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'কাজের বিবরণ',
                  hintText: 'কী কাজ করতে হবে বিস্তারিত লিখুন...',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locController,
                decoration: const InputDecoration(
                  labelText: 'আপনার ঠিকানা',
                  hintText: 'যেমন: মিরপুর-১০, ঢাকা',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'বাজেট / অফারকৃত টাকা',
                  hintText: 'যেমন: ৫০০',
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (descController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('কাজের বিবরণ লিখুন')),
                );
                return;
              }

              final amount = double.tryParse(amountController.text) ?? 0.0;
              if (amount <= 0.0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('অনুগ্রহ করে সঠিক বাজেট দিন')),
                );
                return;
              }

              Navigator.pop(context);

              try {
                final success = await ApiService.sendJobRequest(
                  seekerId: auth.currentUser!.id,
                  karigorId: _provider!.id,
                  description: descController.text,
                  location: locController.text,
                  amount: amount,
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? '✅ অনুরোধ পাঠানো হয়েছে! কারিগর শীঘ্রই যোগাযোগ করবেন।'
                          : '❌ কিছু সমস্যা হয়েছে, আবার চেষ্টা করুন।'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('ত্রুটি: অনুরোধ পাঠানো সম্ভব হয়নি। ($e)'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('পাঠান'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_provider == null) {
      return const Scaffold(
          body: Center(child: Text('কারিগর খুঁজে পাওয়া যায়নি')));
    }

    final p = _provider!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(p.name),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.person, size: 80, color: Colors.white54),
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
                  // Status chips
                  Row(
                    children: [
                      _StatusChip(
                        label: p.isOnline ? 'অনলাইন' : 'অফলাইন',
                        color: p.isOnline ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      if (p.isVerified)
                        const _StatusChip(
                            label: '✓ যাচাইকৃত', color: Colors.blue),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text('${p.rating} (${p.reviewCount} রিভিউ)',
                              style:
                              const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(Icons.work, 'সেবা', p.category),
                  const SizedBox(height: 8),
                  _InfoRow(Icons.phone, 'ফোন', p.phone),
                  const Divider(height: 32),

                  // Bio
                  const Text('পরিচিতি',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(p.bio,
                      style:
                      const TextStyle(fontSize: 15, height: 1.5)),
                  const SizedBox(height: 24),

                  // Reviews
                  const Text('রিভিউ',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _reviews.isEmpty
                      ? const Text('এখনো কোনো রিভিউ নেই',
                      style: TextStyle(color: Colors.grey))
                      : Column(
                    children: _reviews
                        .map((r) => _ReviewCard(
                      name: r['seeker_name'] ?? '',
                      rating: r['rating'] ?? 0,
                      comment: r['comment'] ?? '',
                    ))
                        .toList(),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1), blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.call),
                label: const Text('কল করুন'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${p.phone} তে কল করছে...')),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('কাজের অনুরোধ'),
                onPressed: p.isOnline ? _sendJobRequest : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontWeight: FontWeight.w500)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1B5E20)),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String name;
  final int rating;
  final String comment;
  const _ReviewCard(
      {required this.name, required this.rating, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(name,
                    style:
                    const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Row(
                  children: List.generate(
                    5,
                        (i) => Icon(
                      i < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(comment),
          ],
        ),
      ),
    );
  }
}