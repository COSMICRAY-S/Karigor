import 'package:flutter/material.dart';
import '../../models/provider_model.dart';
import '../../services/karigor_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/request_job_modal.dart';
import 'karigor_direct_chat_screen.dart';

class AllKarigorsScreen extends StatefulWidget {
  final String? initialCategory;
  final String title;

  const AllKarigorsScreen({
    super.key,
    this.initialCategory,
    this.title = 'সকল ধরনের কারিগর',
  });

  @override
  State<AllKarigorsScreen> createState() => _AllKarigorsScreenState();
}

class _AllKarigorsScreenState extends State<AllKarigorsScreen> {
  String? _selectedCategory;
  String _currentSort = 'status';

  final List<Map<String, String>> _filterOptions = [
    {'label': 'সব ধরন', 'value': ''},
    {'label': '🔥 গ্যাস লাইন', 'value': 'গ্যাস'},
    {'label': '🔌 ইলেকট্রিশিয়ান', 'value': 'ইলেকট্রিক'},
    {'label': '🚰 প্লাম্বার', 'value': 'প্লাম্ব'},
    {'label': '🪚 কাঠমিস্ত্রি', 'value': 'কাঠ'},
    {'label': '❄️ এসি', 'value': 'ac'},
    {'label': '🎨 রং মিস্ত্রি', 'value': 'রং'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  void _callProvider(ProviderModel p) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${p.name} (${p.phone.isNotEmpty ? p.phone : "017XXXXXXXX"}) কে কল করা হচ্ছে...'),
        backgroundColor: AppColors.slate,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = KarigorRepository();

    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final providers = repo.getFilteredProviders(
          category: _selectedCategory,
          sort: _currentSort,
        );

        return Scaffold(
          backgroundColor: AppColors.clayBg,
          appBar: AppBar(
            backgroundColor: AppColors.panel,
            title: Text(
              _selectedCategory != null && _selectedCategory!.isNotEmpty
                  ? '$_selectedCategory কারিগর'
                  : widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.ink),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Column(
            children: [
              // Category Filter Row
              Container(
                color: AppColors.panel,
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filterOptions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final item = _filterOptions[i];
                      final isSelected = (_selectedCategory == null && item['value']!.isEmpty) ||
                          (_selectedCategory == item['value']);
                      return FilterChip(
                        label: Text(item['label']!),
                        selected: isSelected,
                        selectedColor: AppColors.terracotta,
                        backgroundColor: AppColors.panel,
                        side: BorderSide(
                          color: isSelected ? AppColors.terracotta : AppColors.line,
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.inkSoft,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        showCheckmark: false,
                        onSelected: (_) {
                          setState(() {
                            _selectedCategory = item['value']!.isEmpty ? null : item['value'];
                          });
                        },
                      );
                    },
                  ),
                ),
              ),

              // Sort Row
              Container(
                color: AppColors.panel,
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
                child: Row(
                  children: [
                    const Text(
                      'সাজান: ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.inkSoft,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _buildSortChip(
                      label: '🟢 সক্রিয় অবস্থা',
                      type: 'status',
                      isActive: _currentSort == 'status',
                    ),
                    const SizedBox(width: 8),
                    _buildSortChip(
                      label: '📍 দূরত্ব',
                      type: 'distance',
                      isActive: _currentSort == 'distance',
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.line),

              // Providers List
              Expanded(
                child: providers.isEmpty
                    ? const Center(
                        child: Text(
                          'এই মুহূর্তে এই ধরনের কোনো কারিগর পাওয়া যায়নি।',
                          style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: providers.length,
                        itemBuilder: (context, i) {
                          return _buildKarigorCard(providers[i]);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortChip({
    required String label,
    required String type,
    required bool isActive,
  }) {
    return InkWell(
      onTap: () => setState(() => _currentSort = type),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.slate : AppColors.panel,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.slate : AppColors.line,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.white : AppColors.inkSoft,
          ),
        ),
      ),
    );
  }

  Widget _buildKarigorCard(ProviderModel k) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.brassGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  k.initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: k.isOnline ? AppColors.success : AppColors.offline,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  k.name,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  k.category,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.terracotta,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      k.isOnline ? '🟢 অনলাইন' : '⚪ অফলাইন',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '📍 ${k.distance.toStringAsFixed(1)} কিমি',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '⭐ ${k.rating.toStringAsFixed(1)}',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSmallButton(
                label: '📞 কল',
                bgColor: AppColors.clayBg,
                textColor: AppColors.slate,
                onTap: () => _callProvider(k),
              ),
              const SizedBox(height: 6),
              _buildSmallButton(
                label: '💬 চ্যাট',
                bgColor: AppColors.sageBg,
                textColor: AppColors.slate,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => KarigorDirectChatScreen(karigor: k),
                    ),
                  );
                },
              ),
              const SizedBox(height: 6),
              _buildSmallButton(
                label: 'অনুরোধ',
                bgColor: AppColors.terracotta,
                textColor: Colors.white,
                onTap: () => RequestJobModal.show(context, karigor: k),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallButton({
    required String label,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.line),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
