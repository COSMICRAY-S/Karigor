import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/auth_provider.dart';
import '../../services/api_service.dart';
import '../../services/karigor_repository.dart';
import '../../models/provider_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/request_job_modal.dart';
import 'all_karigors_screen.dart';
import 'karigor_ai_chat_screen.dart';
import 'karigor_direct_chat_screen.dart';

class SeekerHomeScreen extends StatefulWidget {
  const SeekerHomeScreen({super.key});

  @override
  State<SeekerHomeScreen> createState() => _SeekerHomeScreenState();
}

class _SeekerHomeScreenState extends State<SeekerHomeScreen> {
  int _currentIndex = 0;
  final KarigorRepository _repo = KarigorRepository();

  // Location state
  double? _seekerLat;
  double? _seekerLng;
  bool _isGettingLocation = false;
  String _locationDisplay = 'অবস্থান খোঁজা হচ্ছে...';
  String _locationSub = 'এলাকাভিত্তিক কারিগর দেখাতে অবস্থান প্রয়োজন';

  // Requests state
  List<dynamic> _backendRequests = [];
  bool _isLoadingBackendRequests = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _detectLocation();
      _loadBackendData();
    });
  }

  Future<void> _loadBackendData() async {
    final auth = context.read<AuthProvider>();
    await _repo.fetchFromBackend(lat: _seekerLat, lng: _seekerLng);
    if (auth.currentUser != null) {
      setState(() => _isLoadingBackendRequests = true);
      try {
        final reqs = await ApiService.getJobsForSeeker(auth.currentUser!.id);
        if (mounted) {
          setState(() {
            _backendRequests = reqs;
            _isLoadingBackendRequests = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _isLoadingBackendRequests = false);
      }
    }
  }

  Future<void> _detectLocation() async {
    setState(() {
      _isGettingLocation = true;
      _locationDisplay = 'অবস্থান শনাক্ত করা হচ্ছে...';
      _locationSub = '';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _isGettingLocation = false;
            _locationDisplay = 'পবনা, বাংলাদেশ (আনুমানিক)';
            _locationSub = 'জিপিএস বন্ধ — ডিফল্ট এলাকা দেখানো হচ্ছে';
          });
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _isGettingLocation = false;
            _locationDisplay = 'পবনা, বাংলাদেশ (আনুমানিক)';
            _locationSub = 'অনুমতি দেওয়া হয়নি — ডিফল্ট এলাকা দেখানো হচ্ছে';
          });
        }
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _seekerLat = pos.latitude;
          _seekerLng = pos.longitude;
          _isGettingLocation = false;
          _locationDisplay = 'শনাক্ত হয়েছে (${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)})';
          _locationSub = 'এখন এই অবস্থানের কাছাকাছি কারিগর দেখানো হচ্ছে';
        });
        _repo.fetchFromBackend(lat: pos.latitude, lng: pos.longitude);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
          _locationDisplay = 'পবনা, বাংলাদেশ (আনুমানিক)';
          _locationSub = 'ডিফল্ট এলাকা দেখানো হচ্ছে';
        });
      }
    }
  }

  void _callProvider(ProviderModel p) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${p.name} কে কল করা হচ্ছে...'),
        backgroundColor: AppColors.slate,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── TAB 1: HOME ──────────────────────────────────────────

  Widget _buildHomeTab(AuthProvider auth) {
    final userName = auth.currentUser?.name.isNotEmpty == true ? auth.currentUser!.name : 'রাফি';
    final userInit = userName.trim().isNotEmpty ? userName.trim().substring(0, 1) : 'র';
    final nearby = _repo.allProviders.take(4).toList();

    return RefreshIndicator(
      color: AppColors.terracotta,
      onRefresh: _loadBackendData,
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
                  'স্বাগতম, $userName 👋',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                    fontFamily: 'Baloo Da 2',
                  ),
                ),
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    gradient: AppColors.slateLightGradient,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    userInit,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // AI Banner
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const KarigorAiChatScreen()),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2A4740), Color(0xFF1F3832)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.liftShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: const Text('✨', style: TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI সহকারীকে বলুন আপনার সমস্যা',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Baloo Da 2',
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'বাংলা বা বাংলিশে লিখুন, সরাসরি সমাধান মিলবে',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Service Categories Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'সেবার ধরন',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                    fontFamily: 'Baloo Da 2',
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AllKarigorsScreen(title: 'সকল ধরনের কারিগর'),
                      ),
                    );
                  },
                  child: const Text(
                    'সব দেখুন',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.terracotta,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Category Grid (4 items)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCategoryItem('🔌', 'ইলেকট্রিশিয়ান', 'ইলেকট্রিক'),
                _buildCategoryItem('🔥', 'গ্যাস লাইন', 'গ্যাস'),
                _buildCategoryItem('🚰', 'প্লাম্বার', 'প্লাম্ব'),
                _buildCategoryItem('🪚', 'কাঠমিস্ত্রি', 'কাঠ'),
              ],
            ),
            const SizedBox(height: 26),

            // Nearby Karigors Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'আপনার কাছের কারিগর',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                    fontFamily: 'Baloo Da 2',
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AllKarigorsScreen(title: 'আশেপাশের সকল কারিগর'),
                      ),
                    );
                  },
                  child: const Text(
                    'সব দেখুন',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.terracotta,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Nearby Karigors List
            ...nearby.map((k) => _buildKarigorCard(k)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String icon, String label, String catKey) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AllKarigorsScreen(
              initialCategory: catKey,
              title: '$label কারিগর',
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.line),
              boxShadow: AppTheme.softShadow,
            ),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.inkSoft,
            ),
          ),
        ],
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
              _buildSmallBtn('📞 কল', AppColors.clayBg, AppColors.slate, () => _callProvider(k)),
              const SizedBox(height: 6),
              _buildSmallBtn('💬 চ্যাট', AppColors.sageBg, AppColors.slate, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => KarigorDirectChatScreen(karigor: k)),
                );
              }),
              const SizedBox(height: 6),
              _buildSmallBtn('অনুরোধ', AppColors.terracotta, Colors.white, () {
                RequestJobModal.show(context, karigor: k);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallBtn(String label, Color bg, Color textColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
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

  // ─── TAB 2: REQUESTS ──────────────────────────────────────

  Widget _buildRequestsTab() {
    final sent = _repo.sentRequests;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'সক্রিয় অনুরোধ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
              fontFamily: 'Baloo Da 2',
            ),
          ),
          const SizedBox(height: 12),

          if (_isLoadingBackendRequests)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.terracotta),
                ),
              ),
            ),

          if (sent.isEmpty && _backendRequests.isEmpty && !_isLoadingBackendRequests)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 36),
              alignment: Alignment.center,
              child: const Text(
                'এখনো কোনো সক্রিয় অনুরোধ নেই। AI চ্যাট বা কারিগর তালিকা থেকে অনুরোধ পাঠান।',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
              ),
            )
          else ...[
            ...sent.map((r) => _buildSentRequestCard(r)),
            ..._backendRequests.map((b) => _buildBackendJobCard(b)),
          ],

          const SizedBox(height: 24),
          const Text(
            'সম্পন্ন হয়েছে',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
              fontFamily: 'Baloo Da 2',
            ),
          ),
          const SizedBox(height: 12),

          // Static/Past completed example
          Opacity(
            opacity: 0.75,
            child: Container(
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
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.sageBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text('🚰', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'বাথরুম কল মেরামত',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.ink),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '২ দিন আগে · রহিম মিয়া',
                          style: TextStyle(fontSize: 11.5, color: AppColors.inkSoft),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    '৳ ৪৫০',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentRequestCard(SentJobRequest r) {
    return Container(
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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.sageBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Text('📋', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.karigor?.name ?? 'সাধারণ অনুরোধ',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.ink),
                    ),
                    Text(
                      'পোস্ট করা হয়েছে ${r.timeAgo}',
                      style: const TextStyle(fontSize: 11, color: AppColors.inkSoft),
                    ),
                  ],
                ),
              ),
              Text(
                '৳ ${r.amount.toInt()}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.success),
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
              r.description,
              style: const TextStyle(fontSize: 12.5, color: AppColors.inkSoft),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.inkSoft),
              const SizedBox(width: 4),
              Text(
                r.location,
                style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (r.karigor != null)
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sageBg,
                      foregroundColor: AppColors.slate,
                      elevation: 0,
                      side: const BorderSide(color: AppColors.line),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                    label: const Text('চ্যাট করুন', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => KarigorDirectChatScreen(karigor: r.karigor!),
                        ),
                      );
                    },
                  ),
                ),
              if (r.karigor != null) const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('ডিলিট করুন', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    _repo.deleteRequest(r.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('অনুরোধটি ডিলিট করা হয়েছে')),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackendJobCard(dynamic job) {
    final status = job['status']?.toString() ?? 'pending';
    final desc = job['description']?.toString() ?? '';
    final name = job['karigor_name']?.toString() ?? 'কারিগর';
    final amount = job['amount'] ?? 0;
    final location = job['location']?.toString() ?? 'পবনা';

    return Container(
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
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (status == 'accepted' ? Colors.blue : Colors.orange).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status == 'accepted' ? 'গৃহীত' : 'অপেক্ষমান',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: status == 'accepted' ? Colors.blue : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(fontSize: 12.5)),
          const SizedBox(height: 6),
          Text('📍 $location · ৳ $amount', style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft)),
        ],
      ),
    );
  }

  // ─── TAB 3: PROFILE ───────────────────────────────────────

  Widget _buildProfileTab(AuthProvider auth) {
    final user = auth.currentUser;
    final name = user?.name.isNotEmpty == true ? user!.name : 'রাফি হাসান';
    final initial = name.trim().isNotEmpty ? name.trim().substring(0, 1) : 'র';
    final activeChats = _repo.directChats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Card
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
                    gradient: AppColors.slateLightGradient,
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
                    Text(
                      name,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.ink),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'সেবা গ্রহণকারী',
                      style: TextStyle(fontSize: 12.5, color: AppColors.inkSoft),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Location Section
          const Text(
            'অবস্থান',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.ink, fontFamily: 'Baloo Da 2'),
          ),
          const SizedBox(height: 10),
          Container(
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
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.sageBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Text('📍', style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _locationDisplay,
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.ink),
                          ),
                          if (_locationSub.isNotEmpty)
                            Text(
                              _locationSub,
                              style: const TextStyle(fontSize: 11, color: AppColors.inkSoft),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.slate,
                    minimumSize: const Size.fromHeight(44),
                  ),
                  icon: _isGettingLocation
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.my_location, size: 18),
                  label: const Text('📍 বর্তমান অবস্থান শনাক্ত করুন'),
                  onPressed: _isGettingLocation ? null : _detectLocation,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Direct Chats Section
          const Text(
            'আমার চ্যাটসমূহ',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.ink, fontFamily: 'Baloo Da 2'),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.line),
              boxShadow: AppTheme.softShadow,
            ),
            child: activeChats.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'এখনো কোনো কারিগরের সাথে চ্যাট শুরু হয়নি। কারিগর তালিকা বা AI চ্যাট থেকে "চ্যাট" বাটনে ক্লিক করুন।',
                      style: TextStyle(fontSize: 12.5, color: AppColors.inkSoft),
                    ),
                  )
                : Column(
                    children: activeChats.entries.map((entry) {
                      final karigor = _repo.allProviders.firstWhere(
                        (k) => k.id == entry.key,
                        orElse: () => ProviderModel(
                          id: entry.key,
                          name: 'কারিগর #${entry.key}',
                          category: 'সেবা',
                          rating: 4.8,
                          reviewCount: 10,
                          isOnline: true,
                          isVerified: true,
                          phone: '',
                          bio: '',
                          distance: 1.5,
                        ),
                      );
                      final lastMsg = entry.value.isNotEmpty ? entry.value.last.text : '';

                      return ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => KarigorDirectChatScreen(karigor: karigor)),
                          );
                        },
                        leading: Stack(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: AppColors.brassGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                karigor.initial,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: karigor.isOnline ? AppColors.success : AppColors.offline,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                        title: Text(karigor.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                        subtitle: Text(lastMsg, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.inkSoft),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 24),

          // Account Options
          const Text(
            'অ্যাকাউন্ট',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.ink, fontFamily: 'Baloo Da 2'),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.line),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              children: [
                _buildSettingsRow('⚙️', 'সেটিংস'),
                const Divider(height: 1, color: AppColors.line),
                _buildSettingsRow('🛎️', 'নোটিফিকেশন'),
                const Divider(height: 1, color: AppColors.line),
                _buildSettingsRow('❓', 'সাহায্য'),
                const Divider(height: 1, color: AppColors.line),
                ListTile(
                  leading: const Text('🚪', style: TextStyle(fontSize: 18)),
                  title: const Text('লগআউট', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold, fontSize: 13.5)),
                  onTap: () async {
                    await auth.logout();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, '/role-select', (r) => false);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSettingsRow(String icon, String label) {
    return ListTile(
      leading: Text(icon, style: const TextStyle(fontSize: 18)),
      title: Text(label, style: const TextStyle(fontSize: 13.5, color: AppColors.ink)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.inkSoft),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label শীঘ্রই আসছে')),
        );
      },
    );
  }

  // ─── MAIN BUILD ───────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return ListenableBuilder(
      listenable: _repo,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.clayBg,
          appBar: _currentIndex == 0
              ? null
              : AppBar(
                  backgroundColor: AppColors.panel,
                  automaticallyImplyLeading: false,
                  title: Text(
                    _currentIndex == 2 ? 'আমার অনুরোধসমূহ' : 'প্রোফাইল',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  elevation: 0,
                ),
          body: SafeArea(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                _buildHomeTab(auth),
                const SizedBox(), // Placeholder for index 1 (AI Chat opens as screen or tab)
                _buildRequestsTab(),
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
              onTap: (i) {
                if (i == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const KarigorAiChatScreen()),
                  );
                } else {
                  setState(() => _currentIndex = i);
                }
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'হোম',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.auto_awesome_outlined),
                  activeIcon: Icon(Icons.auto_awesome),
                  label: 'AI চ্যাট',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_outlined),
                  activeIcon: Icon(Icons.receipt_long),
                  label: 'অনুরোধ',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'প্রোফাইল',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
