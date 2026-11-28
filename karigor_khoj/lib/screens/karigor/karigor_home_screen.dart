import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/auth_provider.dart';
import '../../services/api_service.dart';
import '../../services/language_provider.dart';
import '../../widgets/language_switch_button.dart';
import '../../models/provider_model.dart';
import '../../theme/app_theme.dart';

class KarigorHomeScreen extends StatefulWidget {
  const KarigorHomeScreen({super.key});

  @override
  State<KarigorHomeScreen> createState() => _KarigorHomeScreenState();
}

class _KarigorHomeScreenState extends State<KarigorHomeScreen> {
  int _currentIndex = 0;
  bool _isOnline = true;
  List<dynamic> _backendJobs = [];
  bool _isLoading = true;
  bool _isSavingProfile = false;
  bool _isUpdatingLocation = false;

  final _bioController = TextEditingController();
  String _selectedCategory = 'গ্যাস লাইন';

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

  // Prototype sample incoming job feed
  final List<Map<String, dynamic>> _feedJobs = [
    {
      'id': 101,
      'isNew': true,
      'icon': '🔥',
      'title': 'গ্যাস লাইন মেরামত',
      'seeker': 'রাফি হাসান',
      'distance': '১.২ কিমি দূরে',
      'budget': 800,
      'desc': 'রান্নাঘরের গ্যাস লাইন থেকে হালকা গন্ধ পাচ্ছি, দ্রুত একজন কারিগর দরকার।',
      'location': 'পবনা, শহর এলাকা',
      'status': 'pending',
    },
    {
      'id': 102,
      'isNew': false,
      'icon': '🔌',
      'title': 'সুইচ বোর্ড ঠিক করা',
      'seeker': 'নাসরিন আক্তার',
      'distance': '২.৫ কিমি দূরে',
      'budget': 350,
      'desc': 'বেডরুমের সুইচ বোর্ড থেকে স্পার্ক হচ্ছে, আজকের মধ্যে দরকার।',
      'location': 'পবনা, রাধানগর',
      'status': 'pending',
    },
    {
      'id': 103,
      'isNew': false,
      'icon': '🚰',
      'title': 'পানির পাইপ লিক',
      'seeker': 'করিম সাহেব',
      'distance': '৩.১ কিমি দূরে',
      'budget': 500,
      'desc': 'রান্নাঘরের নিচে পাইপ থেকে পানি চুইয়ে পড়ছে।',
      'location': 'পবনা, শালগাড়িয়া',
      'status': 'pending',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileAndJobs();
    });
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileAndJobs() async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser == null) return;

    setState(() => _isLoading = true);
    try {
      final profile = await ApiService.getProviderById(auth.currentUser!.id);
      if (profile != null) {
        _isOnline = profile.isOnline;
        if (_categories.contains(profile.category)) {
          _selectedCategory = profile.category;
        }
        _bioController.text = profile.bio;
      }

      final jobs = await ApiService.getJobsForKarigor(auth.currentUser!.id);
      if (mounted) {
        setState(() {
          _backendJobs = jobs;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleOnlineStatus(bool val) async {
    final auth = context.read<AuthProvider>();
    setState(() => _isOnline = val);

    if (auth.currentUser != null) {
      try {
        await ApiService.updateOnlineStatus(auth.currentUser!.id, val);
      } catch (_) {}
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(val ? 'আপনি এখন অনলাইন 🟢' : 'আপনি এখন অফলাইন'),
          backgroundColor: val ? AppColors.success : AppColors.ink,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _updateGPSLocation() async {
    final auth = context.read<AuthProvider>();
    setState(() => _isUpdatingLocation = true);

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (auth.currentUser != null) {
        await ApiService.updateLocation(auth.currentUser!.id, position.latitude, position.longitude);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ বর্তমান অবস্থান আপডেট করা হয়েছে!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('লোকেশন আপডেট করতে সমস্যা হয়েছে')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingLocation = false);
    }
  }

  void _acceptJob(Map<String, dynamic> job) {
    setState(() {
      job['status'] = 'accepted';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('অনুরোধ গ্রহণ করা হয়েছে!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _skipJob(Map<String, dynamic> job) {
    setState(() {
      job['status'] = 'skipped';
    });
  }

  // ─── TAB 1: JOB FEED ──────────────────────────────────────

  Widget _buildHomeTab(AuthProvider auth) {
    final name = auth.currentUser?.name.isNotEmpty == true ? auth.currentUser!.name : 'জসিম উদ্দিন';
    final initial = name.trim().isNotEmpty ? name.trim().substring(0, 1) : 'জ';

    return RefreshIndicator(
      color: AppColors.terracotta,
      onRefresh: _loadProfileAndJobs,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${context.watch<LanguageProvider>().t('welcome_greeting')}, $name',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                    fontFamily: 'Baloo Da 2',
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const LanguageSwitchButton(isDark: false),
                    const SizedBox(width: 8),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        gradient: AppColors.terracottaGradient,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Online / Offline Toggle Row
            Consumer<LanguageProvider>(
              builder: (context, lang, _) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.panel,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.line),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isOnline ? '🟢 ${lang.t('online')}' : '⚪ ${lang.t('offline')}',
                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: AppColors.ink),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isOnline ? lang.t('status_available') : lang.t('status_unavailable'),
                              style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isOnline,
                        activeThumbColor: AppColors.success,
                        activeTrackColor: AppColors.success.withValues(alpha: 0.3),
                        inactiveThumbColor: AppColors.offline,
                        inactiveTrackColor: AppColors.line,
                        onChanged: _toggleOnlineStatus,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Feed Section Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.watch<LanguageProvider>().t('new_requests_section'),
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                    fontFamily: 'Baloo Da 2',
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.sageBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_feedJobs.where((j) => j['status'] != 'skipped').length}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.slate),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Job Cards Feed
            ..._feedJobs.map((j) => _buildFeedJobCard(j)),

            if (_backendJobs.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('গ্রাহকদের সরাসরি অনুরোধ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              ..._backendJobs.map((b) => _buildBackendJobCard(b)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeedJobCard(Map<String, dynamic> j) {
    final isSkipped = j['status'] == 'skipped';
    final isAccepted = j['status'] == 'accepted';

    return Opacity(
      opacity: isSkipped ? 0.35 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.sageBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(j['icon'] as String, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        j['title'] as String,
                        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: AppColors.ink),
                      ),
                      Text(
                        '${j['seeker']} · ${j['distance']}',
                        style: const TextStyle(fontSize: 11, color: AppColors.inkSoft),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (j['isNew'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: AppColors.terracotta,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('নতুন', style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold)),
                      ),
                    Text(
                      '৳ ${j['budget']}',
                      style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold, color: AppColors.success),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.clayBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                j['desc'] as String,
                style: const TextStyle(fontSize: 12.5, color: AppColors.inkSoft, height: 1.4),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.inkSoft),
                const SizedBox(width: 4),
                Text(
                  j['location'] as String,
                  style: const TextStyle(fontSize: 11, color: AppColors.inkSoft),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isAccepted)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.sageBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '✓ সাড়া দেওয়া হয়েছে — সিকারের কাছে পাঠানো হচ্ছে',
                  style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12.5),
                ),
              )
            else if (!isSkipped)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        backgroundColor: AppColors.clayBg,
                        side: const BorderSide(color: AppColors.line),
                      ),
                      onPressed: () => _skipJob(j),
                      child: const Text('এড়িয়ে যান', style: TextStyle(color: AppColors.inkSoft, fontSize: 12.5)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        backgroundColor: AppColors.slate,
                      ),
                      onPressed: () => _acceptJob(j),
                      child: const Text('সাড়া দিন', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackendJobCard(dynamic b) {
    final status = b['status']?.toString() ?? 'pending';
    final desc = b['description']?.toString() ?? '';
    final seeker = b['seeker_name']?.toString() ?? 'গ্রাহক';
    final amount = b['amount'] ?? 0;
    final jobId = b['id'] is int ? b['id'] as int : int.tryParse('${b['id']}') ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(seeker, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              Text('৳ $amount', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Text(desc, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 10),
          if (status == 'pending')
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.slate),
                    onPressed: () async {
                      await ApiService.updateJobStatus(jobId, 'accepted');
                      _loadProfileAndJobs();
                    },
                    child: const Text('গ্রহণ করুন', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            )
          else
            Text('স্ট্যাটাস: $status', style: const TextStyle(fontSize: 11, color: AppColors.inkSoft)),
        ],
      ),
    );
  }

  // ─── TAB 2: REQUESTS / HISTORY ────────────────────────────

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'কাজের ইতিহাস ও সম্পন্ন কাজ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.ink, fontFamily: 'Baloo Da 2'),
          ),
          const SizedBox(height: 14),
          _buildPastJobCard('গ্যাস ওভেন মেরামত', 'সুমাইয়া রহমান', '৳ ১২০০', 'গতকাল', 'সম্পন্ন'),
          _buildPastJobCard('সিলিন্ডার লাইন সংযোগ', 'কামরুল ইসলাম', '৳ ৬০০', '৩ দিন আগে', 'সম্পন্ন'),
          _buildPastJobCard('কিচেন গ্যাস লিক ফিক্স', 'তানভীর আহমেদ', '৳ ৮৫০', '৫ দিন আগে', 'সম্পন্ন'),
        ],
      ),
    );
  }

  Widget _buildPastJobCard(String title, String seeker, String amount, String date, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.sageBg,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Text('✓', style: TextStyle(fontSize: 20, color: AppColors.success, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.ink)),
                const SizedBox(height: 2),
                Text('$seeker · $date', style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft)),
              ],
            ),
          ),
          Text(amount, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: AppColors.success)),
        ],
      ),
    );
  }

  // ─── TAB 3: RATINGS ───────────────────────────────────────

  Widget _buildRatingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.line),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              children: [
                const Text('৪.৮', style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: AppColors.brassDark)),
                const Text('⭐⭐⭐⭐⭐', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 6),
                const Text('মোট ৯০টি রিভিউ এর ভিত্তিতে', style: TextStyle(fontSize: 12, color: AppColors.inkSoft)),
                const SizedBox(height: 16),
                const Divider(color: AppColors.line),
                const SizedBox(height: 12),
                _buildRatingBar('৫ স্টার', 0.85, '৭৬'),
                _buildRatingBar('৪ স্টার', 0.12, '১১'),
                _buildRatingBar('৩ স্টার', 0.03, '৩'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildReviewCard('রাফি হাসান', 'খুব দ্রুত এসে কাজ সমাধান করে দিয়েছেন। ভদ্র ও আন্তরিক।', '৫.০'),
          _buildReviewCard('নাসরিন আক্তার', 'দক্ষতার সাথে গ্যাস লিকেজ খুঁজে ঠিক করেছেন। ধন্যবাদ!', '৪.৫'),
        ],
      ),
    );
  }

  Widget _buildRatingBar(String label, double ratio, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 50, child: Text(label, style: const TextStyle(fontSize: 11.5))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: ratio, color: AppColors.brass, backgroundColor: AppColors.clayBg),
            ),
          ),
          const SizedBox(width: 8),
          Text(count, style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft)),
        ],
      ),
    );
  }

  Widget _buildReviewCard(String name, String comment, String rating) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
              Text('⭐ $rating', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.brassDark, fontSize: 12.5)),
            ],
          ),
          const SizedBox(height: 6),
          Text(comment, style: const TextStyle(fontSize: 12, color: AppColors.inkSoft)),
        ],
      ),
    );
  }

  // ─── TAB 4: PROFILE ───────────────────────────────────────

  Widget _buildProfileTab(AuthProvider auth) {
    final user = auth.currentUser;
    final name = user?.name.isNotEmpty == true ? user!.name : 'জসিম উদ্দিন';
    final initial = name.trim().isNotEmpty ? name.trim().substring(0, 1) : 'জ';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.line),
              boxShadow: AppTheme.softShadow,
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    gradient: AppColors.terracottaGradient,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.ink)),
                    const SizedBox(height: 2),
                    const Text('কারিগর (Provider)', style: TextStyle(fontSize: 12.5, color: AppColors.inkSoft)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Category setting
          const Text('আপনার সেবার ধরন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(filled: true, fillColor: AppColors.panel),
            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedCategory = val);
            },
          ),
          const SizedBox(height: 16),

          // Bio
          const Text('অভিজ্ঞতা ও দক্ষতা', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 6),
          TextField(
            controller: _bioController,
            maxLines: 2,
            decoration: const InputDecoration(
              filled: true,
              fillColor: AppColors.panel,
              hintText: 'আপনার অভিজ্ঞতা সম্পর্কে লিখুন...',
            ),
          ),
          const SizedBox(height: 16),

          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.slate),
            onPressed: _isSavingProfile
                ? null
                : () async {
                    setState(() => _isSavingProfile = true);
                    if (user != null) {
                      await ApiService.updateProfile(user.id, category: _selectedCategory, bio: _bioController.text);
                    }
                    setState(() => _isSavingProfile = false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('প্রোফাইল আপডেট হয়েছে!'), backgroundColor: AppColors.success),
                      );
                    }
                  },
            child: _isSavingProfile
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('সংরক্ষণ করুন'),
          ),
          const SizedBox(height: 16),

          // GPS update
          Consumer<LanguageProvider>(
            builder: (context, lang, _) {
              return ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.terracotta),
                icon: _isUpdatingLocation
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.my_location, size: 18),
                label: Text(lang.t('update_gps_btn')),
                onPressed: _isUpdatingLocation ? null : _updateGPSLocation,
              );
            },
          ),
          const SizedBox(height: 20),

          // Settings & Language Block
          Consumer<LanguageProvider>(
            builder: (context, lang, _) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.line),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Text('🌐', style: TextStyle(fontSize: 18)),
                      title: Text(lang.t('language'), style: const TextStyle(fontSize: 13.5, color: AppColors.ink, fontWeight: FontWeight.w600)),
                      subtitle: Text(lang.isEnglish ? 'English' : 'বাংলা', style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft)),
                      trailing: const LanguageSwitchButton(isDark: false),
                    ),
                    const Divider(height: 1, color: AppColors.line),
                    ListTile(
                      leading: const Text('⚙️', style: TextStyle(fontSize: 18)),
                      title: Text(lang.t('settings'), style: const TextStyle(fontSize: 13.5, color: AppColors.ink)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.inkSoft),
                      onTap: () => Navigator.pushNamed(context, '/settings'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Logout
          Consumer<LanguageProvider>(
            builder: (context, lang, _) {
              return OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                  minimumSize: const Size.fromHeight(48),
                ),
                icon: const Icon(Icons.logout),
                label: Text(lang.t('logout')),
                onPressed: () async {
                  await auth.logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/role-select', (r) => false);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: AppColors.clayBg,
      appBar: _currentIndex == 0
          ? null
          : AppBar(
              backgroundColor: AppColors.panel,
              automaticallyImplyLeading: false,
              title: Text(
                _currentIndex == 1
                    ? lang.t('nav_history')
                    : _currentIndex == 2
                        ? lang.t('nav_rating')
                        : lang.t('profile_title'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: lang.t('settings'),
                  onPressed: () => Navigator.pushNamed(context, '/settings'),
                ),
              ],
              elevation: 0,
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.terracotta))
          : SafeArea(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  _buildHomeTab(auth),
                  _buildHistoryTab(),
                  _buildRatingTab(),
                  _buildProfileTab(auth),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.panel,
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: AppColors.panel,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.terracotta,
          unselectedItemColor: AppColors.inkSoft,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 11),
          onTap: (i) => setState(() => _currentIndex = i),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: lang.t('nav_dashboard'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.history_outlined),
              activeIcon: const Icon(Icons.history),
              label: lang.t('nav_history'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.star_outline),
              activeIcon: const Icon(Icons.star),
              label: lang.t('nav_rating'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: lang.t('nav_profile'),
            ),
          ],
        ),
      ),
    );
  }
}
