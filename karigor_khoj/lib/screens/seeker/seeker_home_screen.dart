import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/provider_model.dart';
import '../../widgets/provider_card.dart';
import '../../widgets/category_chip.dart';

class SeekerHomeScreen extends StatefulWidget {
  const SeekerHomeScreen({super.key});

  @override
  State<SeekerHomeScreen> createState() => _SeekerHomeScreenState();
}

class _SeekerHomeScreenState extends State<SeekerHomeScreen> {
  int _currentIndex = 0;
  List<ProviderModel> _providers = [];
  bool _isLoadingProviders = true;
  String? _selectedCategory;

  // Seeker GPS state
  double? _seekerLat;
  double? _seekerLng;
  bool _isGettingLocation = false;
  String _locationLabel = 'অবস্থান অজানা';

  // Search Tab state
  final _searchController = TextEditingController();
  List<ProviderModel> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  // Requests Tab state
  List<dynamic> _myRequests = [];
  bool _isLoadingRequests = true;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'সব', 'icon': Icons.grid_view},
    {'label': 'প্লাম্বার', 'icon': Icons.plumbing},
    {'label': 'ইলেকট্রিশিয়ান', 'icon': Icons.electrical_services},
    {'label': 'দর্জি', 'icon': Icons.checkroom},
    {'label': 'রঙ মিস্ত্রি', 'icon': Icons.format_paint},
    {'label': 'AC মেরামত', 'icon': Icons.ac_unit},
    {'label': 'গাড়ি মেকানিক', 'icon': Icons.car_repair},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _detectLocationThenLoad();
      _loadMyRequests();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Tries to get GPS location first, then loads providers.
  /// Falls back to loading all providers if permission denied.
  Future<void> _detectLocationThenLoad() async {
    setState(() => _isGettingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isGettingLocation = false;
          _locationLabel = 'GPS বন্ধ আছে';
        });
        await _loadProviders();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _isGettingLocation = false;
          _locationLabel = 'অনুমতি নেই';
        });
        await _loadProviders();
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _seekerLat = pos.latitude;
        _seekerLng = pos.longitude;
        _isGettingLocation = false;
        _locationLabel =
            '${pos.latitude.toStringAsFixed(3)}, ${pos.longitude.toStringAsFixed(3)}';
      });

      await _loadProviders(category: _selectedCategory);
    } catch (e) {
      setState(() {
        _isGettingLocation = false;
        _locationLabel = 'ত্রুটি';
      });
      await _loadProviders();
    }
  }

  Future<void> _refreshLocation() async {
    await _detectLocationThenLoad();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _seekerLat != null
                ? '✅ অবস্থান আপডেট হয়েছে। কাছের ৫ কি.মি. কারিগর দেখাচ্ছে।'
                : '⚠️ অবস্থান পাওয়া যায়নি। সব কারিগর দেখাচ্ছে।',
          ),
          backgroundColor: _seekerLat != null ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  Future<void> _loadProviders({String? category}) async {
    setState(() => _isLoadingProviders = true);
    try {
      final providers = await ApiService.getProviders(
        category: category,
        lat: _seekerLat,
        lng: _seekerLng,
        radius: 5.0,
      );
      setState(() {
        _providers = providers;
        _isLoadingProviders = false;
      });
    } catch (e) {
      setState(() => _isLoadingProviders = false);
      _showErrorSnackBar('লোড করতে ত্রুটি: $e');
    }
  }

  Future<void> _loadMyRequests() async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser == null) return;
    setState(() => _isLoadingRequests = true);
    try {
      final requests = await ApiService.getJobsForSeeker(auth.currentUser!.id);
      setState(() {
        _myRequests = requests;
        _isLoadingRequests = false;
      });
    } catch (e) {
      setState(() => _isLoadingRequests = false);
      _showErrorSnackBar('অনুরোধসমূহ লোড করতে ত্রুটি: $e');
    }
  }

  Future<void> _searchProviders(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });
    try {
      final results = await ApiService.getProviders(
        category: query.trim(),
        lat: _seekerLat,
        lng: _seekerLng,
        radius: 20.0, // wider radius for search
      );
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      _showErrorSnackBar('অনুসন্ধান ব্যর্থ: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // ─── Complete & Rate job ───────────────────────────────────

  void _completeAndRateJob(int jobId, int providerId) {
    final commentController = TextEditingController();
    int selectedRating = 5;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('কাজ সম্পন্ন ও রেটিং'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                    'কাজটি কি সফলভাবে সম্পন্ন হয়েছে? কারিগরের জন্য একটি রেটিং এবং মন্তব্য দিন।'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final ratingVal = index + 1;
                    return IconButton(
                      icon: Icon(
                        ratingVal <= selectedRating
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                      onPressed: () =>
                          setDialogState(() => selectedRating = ratingVal),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: commentController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'মন্তব্য লিখুন',
                    hintText: 'যেমন: চমৎকার কাজ করেছেন!',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('বাতিল'),
            ),
            ElevatedButton(
              onPressed: () async {
                final comment = commentController.text.trim();
                if (comment.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('একটি মন্তব্য লিখুন')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                setState(() => _isLoadingRequests = true);
                try {
                  final auth = context.read<AuthProvider>();
                  await ApiService.updateJobStatus(jobId, 'completed');
                  await ApiService.addReview(
                      providerId, auth.currentUser!.id, selectedRating, comment);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          '✅ কাজ সম্পন্ন হয়েছে এবং রেটিং সফলভাবে জমা হয়েছে!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadMyRequests();
                  _loadProviders(category: _selectedCategory);
                } catch (e) {
                  setState(() => _isLoadingRequests = false);
                  _showErrorSnackBar('ত্রুটি: $e');
                }
              },
              child: const Text('সম্পন্ন করুন'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── TAB WIDGETS ──────────────────────────────────────────

  Widget _buildHomeTab(AuthProvider auth) {
    return RefreshIndicator(
      onRefresh: () => _loadProviders(category: _selectedCategory),
      child: CustomScrollView(
        slivers: [
          // Location Status Banner
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _seekerLat != null
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _seekerLat != null
                      ? Colors.green.shade200
                      : Colors.orange.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _seekerLat != null ? Icons.location_on : Icons.location_off,
                    color: _seekerLat != null ? Colors.green : Colors.orange,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _isGettingLocation
                        ? const Text('অবস্থান খোঁজা হচ্ছে...',
                            style: TextStyle(fontSize: 13))
                        : Text(
                            _seekerLat != null
                                ? 'আপনার কাছের ৫ কি.মি. কারিগর দেখাচ্ছে'
                                : 'GPS চালু করুন — কাছের কারিগর দেখতে',
                            style: const TextStyle(fontSize: 13),
                          ),
                  ),
                  if (_isGettingLocation)
                    const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                ],
              ),
            ),
          ),

          // Categories
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('সেবার ধরন',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final cat = _categories[i];
                        final label = cat['label'] as String;
                        final isSelected =
                            (i == 0 && _selectedCategory == null) ||
                                _selectedCategory == label;
                        return CategoryChip(
                          label: label,
                          icon: cat['icon'] as IconData,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedCategory = i == 0 ? null : label;
                            });
                            _loadProviders(category: i == 0 ? null : label);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _seekerLat != null
                        ? 'কাছের কারিগর (অনলাইন প্রথমে)'
                        : 'সকল কারিগর',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (_isLoadingProviders)
                    const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                ],
              ),
            ),
          ),

          // Provider list
          if (_isLoadingProviders)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_providers.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_search_rounded,
                          size: 72, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(
                        _seekerLat != null
                            ? '৫ কি.মি. এর মধ্যে কোনো কারিগর পাওয়া যায়নি।\nত্রিজ্যা বাড়াতে ক্যাটাগরি পরিবর্তন করুন।'
                            : 'কোনো কারিগর পাওয়া যায়নি।',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('আবার চেষ্টা করুন'),
                        onPressed: () =>
                            _loadProviders(category: _selectedCategory),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ProviderCard(
                      provider: _providers[i],
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/provider-detail',
                        arguments: _providers[i].id,
                      ).then((_) => _loadMyRequests()),
                    ),
                  ),
                  childCount: _providers.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'যেমন: প্লাম্বার, ইলেকট্রিশিয়ান...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onSubmitted: _searchProviders,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20)),
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () => _searchProviders(_searchController.text),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isSearching
              ? const Center(child: CircularProgressIndicator())
              : !_hasSearched
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_search_rounded,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('পেশা বা ক্যাটাগরি লিখে কারিগর খুঁজুন'),
                        ],
                      ),
                    )
                  : _searchResults.isEmpty
                      ? const Center(
                          child: Text('কোনো কারিগর পাওয়া যায়নি'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _searchResults.length,
                          itemBuilder: (_, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ProviderCard(
                              provider: _searchResults[i],
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/provider-detail',
                                arguments: _searchResults[i].id,
                              ).then((_) => _loadMyRequests()),
                            ),
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _buildRequestsTab() {
    if (_isLoadingRequests) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_myRequests.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadMyRequests,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: 400,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('আপনি এখনো কোনো কাজের অনুরোধ পাঠাননি'),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMyRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myRequests.length,
        itemBuilder: (ctx, index) {
          final req = _myRequests[index];
          final status = req['status'] as String;
          Color statusColor = Colors.orange;
          String statusText = 'অপেক্ষমান';

          if (status == 'accepted') {
            statusColor = Colors.blue;
            statusText = 'চলমান';
          } else if (status == 'completed') {
            statusColor = Colors.green;
            statusText = 'সম্পন্ন';
          } else if (status == 'rejected') {
            statusColor = Colors.red;
            statusText = 'প্রত্যাখ্যাত';
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        req['karigor_name'] ?? 'কারিগর',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor),
                        ),
                        child: Text(statusText,
                            style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(req['description'] ?? '',
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(req['location'] ?? 'ঠিকানা দেওয়া হয়নি',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text(' ৳ ',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                      Text('${req['amount'] ?? 0} টাকা',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (status == 'accepted') ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('কাজটি সম্পন্ন হয়েছে'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        onPressed: () => _completeAndRateJob(
                            req['id'], req['karigor_id'] ?? 0),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileTab(AuthProvider auth) {
    final user = auth.currentUser;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF1B5E20),
            child: Icon(Icons.person, size: 64, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            user?.name ?? 'সেবা গ্রহণকারী',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading:
                      const Icon(Icons.phone, color: Color(0xFF1B5E20)),
                  title: const Text('মোবাইল নম্বর'),
                  subtitle: Text(user?.phone ?? 'প্রদান করা হয়নি'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading:
                      const Icon(Icons.email, color: Color(0xFF1B5E20)),
                  title: const Text('ইমেইল এড্রেস'),
                  subtitle: Text(user?.email ?? 'প্রদান করা হয়নি'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.badge_outlined,
                      color: Color(0xFF1B5E20)),
                  title: const Text('রোল / Role'),
                  subtitle: const Text('সেবা গ্রহণকারী (Seeker)'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.location_on,
                      color: Color(0xFF1B5E20)),
                  title: const Text('বর্তমান অবস্থান'),
                  subtitle: Text(_locationLabel),
                ),
              ],
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              minimumSize: const Size.fromHeight(50),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('লগআউট করুন'),
            onPressed: () async {
              await auth.logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/role-select', (r) => false);
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ─── BUILD ────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    String title = auth.currentUser?.name ?? 'কারিগর খোঁজ';
    if (_currentIndex == 1) title = 'কারিগর খুঁজুন';
    if (_currentIndex == 2) title = 'আমার অনুরোধ সমূহ';
    if (_currentIndex == 3) title = 'আমার প্রোফাইল';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(title,
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          // GPS button — only show on home tab
          if (_currentIndex == 0)
            _isGettingLocation
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2)),
                  )
                : IconButton(
                    icon: Icon(
                      _seekerLat != null
                          ? Icons.gps_fixed
                          : Icons.gps_not_fixed,
                      color: _seekerLat != null ? Colors.white : Colors.white70,
                    ),
                    tooltip: 'আমার অবস্থান থেকে কাছের কারিগর খুঁজুন',
                    onPressed: _refreshLocation,
                  ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'লগআউট',
            onPressed: () async {
              await auth.logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/role-select', (r) => false);
              }
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(auth),
          _buildSearchTab(),
          _buildRequestsTab(),
          _buildProfileTab(auth),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1B5E20),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 2) _loadMyRequests();
          if (index == 0) _loadProviders(category: _selectedCategory);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'হোম'),
          BottomNavigationBarItem(
              icon: Icon(Icons.search), label: 'খুঁজুন'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: 'অনুরোধ'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'প্রোফাইল'),
        ],
      ),
    );
  }
}