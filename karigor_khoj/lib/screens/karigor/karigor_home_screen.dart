import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/provider_model.dart';
import '../../widgets/provider_card.dart';

class KarigorHomeScreen extends StatefulWidget {
  const KarigorHomeScreen({super.key});

  @override
  State<KarigorHomeScreen> createState() => _KarigorHomeScreenState();
}

class _KarigorHomeScreenState extends State<KarigorHomeScreen> {
  int _currentIndex = 0;
  bool _isOnline = false;
  List<dynamic> _jobs = [];
  List<ProviderModel> _providers = [];
  bool _isLoading = true;
  bool _isSavingProfile = false;
  bool _isUpdatingLocation = false;

  // Profile Tab controllers
  final _bioController = TextEditingController();
  String _selectedCategory = 'প্লাম্বার';

  // Search Tab state
  final _searchController = TextEditingController();
  List<ProviderModel> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileAndJobs();
    });
  }

  @override
  void dispose() {
    _bioController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileAndJobs() async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser == null) return;

    setState(() => _isLoading = true);
    try {
      // 1. Get current provider profile (to read online/offline and category status)
      final profile = await ApiService.getProviderById(auth.currentUser!.id);
      if (profile != null) {
        _isOnline = profile.isOnline;
        if (_categories.contains(profile.category)) {
          _selectedCategory = profile.category;
        }
        _bioController.text = profile.bio;
      }

      // 2. Load Job Requests
      final jobs = await ApiService.getJobsForKarigor(auth.currentUser!.id);

      // 3. Load nearby providers
      final providers = await ApiService.getProviders();

      if (mounted) {
        setState(() {
          _jobs = jobs;
          _providers = providers.where((p) => p.id != auth.currentUser!.id).toList(); // Exclude self
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('লোড করতে ত্রুটি: $e');
      }
    }
  }

  Future<void> _toggleOnlineStatus(bool val) async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser == null) return;

    setState(() {
      _isOnline = val;
    });

    try {
      final success = await ApiService.updateOnlineStatus(auth.currentUser!.id, val);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(val ? '✅ আপনি এখন অনলাইনে আছেন' : '❌ আপনি এখন অফলাইনে আছেন'),
            backgroundColor: val ? Colors.green : Colors.grey.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isOnline = !val); // Revert status
        _showErrorSnackBar('স্ট্যাটাস পরিবর্তনে ব্যর্থতা: $e');
      }
    }
  }

  Future<void> _updateGPSLocation() async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser == null) return;

    setState(() => _isUpdatingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('জিপিএস লোকেশন সার্ভিসটি বন্ধ রয়েছে। দয়া করে চালু করুন।');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('লোকেশন পারমিশন প্রত্যাখ্যান করা হয়েছে।');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('লোকেশন পারমিশন চিরতরে বন্ধ রয়েছে। সেটিংস থেকে এটি চালু করুন।');
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final success = await ApiService.updateLocation(
          auth.currentUser!.id, position.latitude, position.longitude);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ জিপিএস দিয়ে অবস্থান আপডেট করা হয়েছে! (Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)})'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingLocation = false);
      }
    }
  }

  Future<void> _updateJobStatus(int jobId, String status) async {
    setState(() => _isLoading = true);
    try {
      final success = await ApiService.updateJobStatus(jobId, status);
      if (success) {
        await _loadProfileAndJobs(); // list refresh
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(status == 'accepted'
                  ? '✅ কাজ গ্রহণ করা হয়েছে'
                  : status == 'completed'
                      ? '✅ কাজ সম্পন্ন করা হয়েছে'
                      : '❌ কাজ প্রত্যাখ্যান করা হয়েছে'),
              backgroundColor: status == 'rejected' ? Colors.red : Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('ত্রুটি: $e');
      }
    }
  }

  Future<void> _saveProfile() async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser == null) return;

    setState(() => _isSavingProfile = true);
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
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('প্রোফাইল সংরক্ষণ ব্যর্থ: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingProfile = false);
      }
    }
  }

  Future<void> _searchProviders(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });
    try {
      final results = await ApiService.getProviders(category: query.trim());
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        _showErrorSnackBar('অনুসন্ধান ব্যর্থ: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- Widgets for tabs ---

  Widget _buildHomeTab(AuthProvider auth) {
    final pending = _jobs.where((j) => j['status'] == 'pending').length;
    final accepted = _jobs.where((j) => j['status'] == 'accepted').length;
    final completed = _jobs.where((j) => j['status'] == 'completed').length;

    return RefreshIndicator(
      onRefresh: _loadProfileAndJobs,
      child: CustomScrollView(
        slivers: [
          // Online Toggle Box
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isOnline ? Colors.green : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isOnline ? 'আপনি এখন অনলাইনে আছেন' : 'আপনি এখন অফলাইনে আছেন',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          _isOnline ? 'গ্রাহকরা আপনার প্রোফাইল দেখতে পাচ্ছে' : 'প্রোফাইল দেখাতে অনলাইন করুন',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isOnline,
                    activeColor: const Color(0xFFE65100),
                    onChanged: _toggleOnlineStatus,
                  ),
                ],
              ),
            ),
          ),

          // Stats Row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _StatCard(label: 'অপেক্ষায়', value: '$pending', icon: Icons.hourglass_empty, color: Colors.orange),
                  const SizedBox(width: 12),
                  _StatCard(label: 'চলমান', value: '$accepted', icon: Icons.work, color: Colors.blue),
                  const SizedBox(width: 12),
                  _StatCard(label: 'সম্পন্ন', value: '$completed', icon: Icons.check_circle, color: Colors.green),
                ],
              ),
            ),
          ),

          // Other providers list header
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8),
              child: Text('অন্যান্য কাছের কারিগরগণ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),

          if (_providers.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text('কাছে অন্য কোনো কারিগর পাওয়া যায়নি'),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      ),
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

  Widget _buildRequestsTab() {
    if (_jobs.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadProfileAndJobs,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            alignment: Alignment.center,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 12),
                Text('কোনো কাজের অনুরোধ পাওয়া যায়নি', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProfileAndJobs,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _jobs.length,
        itemBuilder: (ctx, i) {
          final job = _jobs[i];
          final status = job['status']?.toString() ?? 'pending';
          final jobId = job['id'] is int ? job['id'] as int : int.tryParse('${job['id']}') ?? 0;

          Color statusColor = Colors.orange;
          String statusLabel = 'অপেক্ষায়';

          if (status == 'accepted') {
            statusColor = Colors.blue;
            statusLabel = 'গৃহীত';
          } else if (status == 'completed') {
            statusColor = Colors.green;
            statusLabel = 'সম্পন্ন';
          } else if (status == 'rejected') {
            statusColor = Colors.red;
            statusLabel = 'প্রত্যাখ্যাত';
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, size: 18, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(job['seeker_name']?.toString() ?? 'গ্রাহক', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor),
                        ),
                        child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(job['description']?.toString() ?? '', style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 8),
                  if (job['location'] != null && job['location'].toString().isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(job['location'].toString(), style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(job['seeker_phone']?.toString() ?? '', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text(' ৳ ', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                      Text('${job['amount'] ?? 0} টাকা', style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (status == 'pending') ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                            onPressed: () => _updateJobStatus(jobId, 'rejected'),
                            child: const Text('প্রত্যাখ্যান'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE65100)),
                            onPressed: () => _updateJobStatus(jobId, 'accepted'),
                            child: const Text('গ্রহণ করুন'),
                          ),
                        ),
                      ],
                    ),
                  ] else if (status == 'accepted') ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        icon: const Icon(Icons.check),
                        label: const Text('কাজ সম্পন্ন হয়েছে'),
                        onPressed: () => _updateJobStatus(jobId, 'completed'),
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
                style: IconButton.styleFrom(backgroundColor: const Color(0xFFE65100)),
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
                          Icon(Icons.person_search_rounded, size: 64, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('ক্যাটাগরি লিখে অন্যান্য কারিগর খুঁজুন'),
                        ],
                      ),
                    )
                  : _searchResults.isEmpty
                      ? const Center(child: Text('কোনো কারিগর পাওয়া যায়নি'))
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
                              ),
                            ),
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _buildProfileTab(AuthProvider auth) {
    final user = auth.currentUser;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: const Color(0xFFE65100).withOpacity(0.1),
              child: const Icon(Icons.person, size: 54, color: Color(0xFFE65100)),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              user?.name ?? 'কারিগর',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),

          // User details Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.phone, color: Color(0xFFE65100)),
                  title: const Text('মোবাইল নম্বর'),
                  subtitle: Text(user?.phone ?? 'প্রদান করা হয়নি'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email, color: Color(0xFFE65100)),
                  title: const Text('ইমেইল এড্রেস'),
                  subtitle: Text(user?.email ?? 'প্রদান করা হয়নি'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.badge_outlined, color: Color(0xFFE65100)),
                  title: const Text('রোল / Role'),
                  subtitle: const Text('কারিগর (Provider)'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // GPS update location button
          Card(
            elevation: 0,
            color: Colors.orange.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.orange.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.gps_fixed, color: Color(0xFFE65100)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('জিপিএস দিয়ে অবস্থান সেট করুন', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('আপনার অবস্থান গ্রাহকদের সাথে শেয়ার করুন', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE65100)),
                    onPressed: _isUpdatingLocation ? null : _updateGPSLocation,
                    child: _isUpdatingLocation
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('অপ্টিমাইজ GPS'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text('সেবার ধরন (Category)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _categories.contains(_selectedCategory) ? _selectedCategory : _categories.first,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.work)),
            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedCategory = val);
            },
          ),
          const SizedBox(height: 16),

          const Text('পরিচিতি / বায়ো (Bio)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _bioController,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'আপনার অভিজ্ঞতা ও দক্ষতা সম্পর্কে লিখুন...'),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE65100)),
              icon: _isSavingProfile
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save),
              label: const Text('প্রোফাইল সংরক্ষণ করুন'),
              onPressed: _isSavingProfile ? null : _saveProfile,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('লগআউট করুন'),
              onPressed: () async {
                await auth.logout();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/role-select', (r) => false);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    String title = auth.currentUser?.name ?? 'কারিগর ড্যাশবোর্ড';
    if (_currentIndex == 1) title = 'কাজের অনুরোধসমূহ';
    if (_currentIndex == 2) title = 'অন্যান্য কারিগর খুঁজুন';
    if (_currentIndex == 3) title = 'আমার প্রোফাইল সেটিংস';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFE65100),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.gps_fixed),
            tooltip: 'GPS লোকেশন আপডেট',
            onPressed: _isUpdatingLocation ? null : _updateGPSLocation,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'লগআউট',
            onPressed: () async {
              await auth.logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/role-select', (r) => false);
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE65100)))
          : IndexedStack(
              index: _currentIndex,
              children: [
                _buildHomeTab(auth),
                _buildRequestsTab(),
                _buildSearchTab(),
                _buildProfileTab(auth),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFE65100),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 0 || index == 1) {
            _loadProfileAndJobs();
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'হোম'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'অনুরোধ'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'খুঁজুন'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'প্রোফাইল'),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
