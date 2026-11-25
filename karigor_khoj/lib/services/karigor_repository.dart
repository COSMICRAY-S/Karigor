import 'package:flutter/foundation.dart';
import '../models/provider_model.dart';
import 'api_service.dart';

class DirectChatMessage {
  final bool isUser;
  final String text;
  final DateTime time;

  DirectChatMessage({
    required this.isUser,
    required this.text,
    DateTime? time,
  }) : time = time ?? DateTime.now();
}

class SentJobRequest {
  final int id;
  final ProviderModel? karigor;
  final String description;
  final String location;
  final double amount;
  final String timeAgo;
  final String status;

  SentJobRequest({
    required this.id,
    this.karigor,
    required this.description,
    required this.location,
    required this.amount,
    this.timeAgo = 'এইমাত্র',
    this.status = 'pending',
  });
}

class KarigorRepository extends ChangeNotifier {
  static final KarigorRepository _instance = KarigorRepository._internal();
  factory KarigorRepository() => _instance;
  KarigorRepository._internal() {
    _initDefaultProviders();
  }

  final List<ProviderModel> _allProviders = [];
  bool _isLoading = false;
  String? _selectedCategory;
  String _currentSort = 'status'; // 'status' or 'distance'

  // Direct 1-on-1 Chat histories: karigorId -> List<DirectChatMessage>
  final Map<int, List<DirectChatMessage>> _directChats = {};

  // Sent requests
  final List<SentJobRequest> _sentRequests = [
    SentJobRequest(
      id: 99,
      karigor: ProviderModel(
        id: 1,
        name: "মোঃ জসিম উদ্দিন",
        category: "গ্যাস লাইন",
        rating: 4.8,
        reviewCount: 90,
        isOnline: true,
        isVerified: true,
        phone: "01700000001",
        bio: "অভিজ্ঞ গ্যাস লাইন মিস্ত্রি",
        distance: 1.2,
      ),
      description: "রান্নাঘরের চুলা থেকে হালকা গন্ধ পাচ্ছি, দ্রুত চেক করা দরকার।",
      location: "পবনা, শহর এলাকা",
      amount: 800,
      timeAgo: '১০ মিনিট আগে',
      status: 'pending',
    )
  ];

  List<ProviderModel> get allProviders => List.unmodifiable(_allProviders);
  bool get isLoading => _isLoading;
  String? get selectedCategory => _selectedCategory;
  String get currentSort => _currentSort;
  List<SentJobRequest> get sentRequests => List.unmodifiable(_sentRequests);
  Map<int, List<DirectChatMessage>> get directChats => _directChats;

  void _initDefaultProviders() {
    if (_allProviders.isNotEmpty) return;
    final defaults = [
      ProviderModel(
        id: 1,
        name: "মোঃ জসিম উদ্দিন",
        category: "গ্যাস লাইন",
        rating: 4.8,
        reviewCount: 90,
        isOnline: true,
        isVerified: true,
        phone: "01711000001",
        bio: "গ্যাস সিলিন্ডার ও পাইপলাইন ইনস্টলেশন ও লিক মেরামত বিশেষজ্ঞ।",
        distance: 1.2,
      ),
      ProviderModel(
        id: 2,
        name: "আবুল কালাম",
        category: "ইলেকট্রিশিয়ান",
        rating: 4.6,
        reviewCount: 64,
        isOnline: true,
        isVerified: true,
        phone: "01711000002",
        bio: "বাসাবাড়ির ওয়্যারিং, শর্ট সার্কিট ও সুইচবোর্ড মেরামত।",
        distance: 2.5,
      ),
      ProviderModel(
        id: 3,
        name: "রহিম মিয়া",
        category: "প্লাম্বার",
        rating: 4.7,
        reviewCount: 112,
        isOnline: false,
        isVerified: true,
        phone: "01711000003",
        bio: "বাথরুম ফিটিংস, পাইপ লিক ও পানির মোটর সার্ভিসিং।",
        distance: 3.1,
      ),
      ProviderModel(
        id: 4,
        name: "সোহেল রানা",
        category: "গ্যাস লাইন",
        rating: 4.5,
        reviewCount: 38,
        isOnline: true,
        isVerified: false,
        phone: "01711000004",
        bio: "চুলা সার্ভিসিং ও গ্যাস লিকেজ সমাধান।",
        distance: 2.0,
      ),
      ProviderModel(
        id: 5,
        name: "নজরুল ইসলাম",
        category: "ইলেকট্রিশিয়ান",
        rating: 4.4,
        reviewCount: 51,
        isOnline: false,
        isVerified: true,
        phone: "01711000005",
        bio: "বৈদ্যুতিক লাইন ও ফ্যান/লাইট ইনস্টলেশন।",
        distance: 4.3,
      ),
      ProviderModel(
        id: 6,
        name: "শাহাদাত হোসেন",
        category: "কাঠমিস্ত্রি",
        rating: 4.9,
        reviewCount: 75,
        isOnline: true,
        isVerified: true,
        phone: "01711000006",
        bio: "দরজা, জানালা ও আলমারি মেরামত ও নতুন তৈরি।",
        distance: 1.8,
      ),
      ProviderModel(
        id: 7,
        name: "ইকবাল হোসেন",
        category: "প্লাম্বার",
        rating: 4.3,
        reviewCount: 29,
        isOnline: true,
        isVerified: false,
        phone: "01711000007",
        bio: "পানির পাইপ লিক ও স্যানিটারি মেরামত।",
        distance: 2.9,
      ),
      ProviderModel(
        id: 8,
        name: "মিজানুর রহমান",
        category: "গ্যাস লাইন",
        rating: 4.7,
        reviewCount: 82,
        isOnline: true,
        isVerified: true,
        phone: "01711000008",
        bio: "গ্যাস লাইন বিশেষজ্ঞ ও আধুনিক চুলা মেকানিক।",
        distance: 0.9,
      ),
      ProviderModel(
        id: 9,
        name: "তোফাজ্জল হোসেন",
        category: "ইলেকট্রিশিয়ান",
        rating: 4.2,
        reviewCount: 22,
        isOnline: false,
        isVerified: false,
        phone: "01711000009",
        bio: "বাসা ও দোকানের সাধারণ ইলেকট্রিক মেরামত।",
        distance: 3.6,
      ),
      ProviderModel(
        id: 10,
        name: "আলাউদ্দিন খান",
        category: "কাঠমিস্ত্রি",
        rating: 4.6,
        reviewCount: 47,
        isOnline: true,
        isVerified: true,
        phone: "01711000010",
        bio: "ফার্নিচার পলিশ ও নতুন আসবাবপত্র প্রস্তুতকারক।",
        distance: 2.2,
      ),
      ProviderModel(
        id: 11,
        name: "ফরহাদ হোসেন",
        category: "প্লাম্বার",
        rating: 4.8,
        reviewCount: 99,
        isOnline: true,
        isVerified: true,
        phone: "01711000011",
        bio: "কমোড, বেসিন ও মেইন পানির লাইন সমাধান।",
        distance: 1.5,
      ),
      ProviderModel(
        id: 12,
        name: "রফিকুল ইসলাম",
        category: "রং মিস্ত্রি",
        rating: 4.5,
        reviewCount: 33,
        isOnline: true,
        isVerified: false,
        phone: "01711000012",
        bio: "ওয়াল পেইন্টিং, ওয়েদার কোট ও ডিস্টেম্পার কাজ।",
        distance: 3.3,
      ),
      ProviderModel(
        id: 13,
        name: "শামসুল আলম",
        category: "AC মেরামত",
        rating: 4.4,
        reviewCount: 41,
        isOnline: false,
        isVerified: true,
        phone: "01711000013",
        bio: "এসি গ্যাস রিফিল, সার্ভিসিং ও কুলিং সমস্যা।",
        distance: 4.0,
      ),
      ProviderModel(
        id: 14,
        name: "বাবুল আক্তার",
        category: "গ্যাস লাইন",
        rating: 4.1,
        reviewCount: 18,
        isOnline: false,
        isVerified: false,
        phone: "01711000014",
        bio: "চুলা মেরামত ও গ্যাস পাইপ ফিটিং।",
        distance: 5.1,
      ),
      ProviderModel(
        id: 15,
        name: "হাফিজুর রহমান",
        category: "ইলেকট্রিশিয়ান",
        rating: 4.9,
        reviewCount: 120,
        isOnline: true,
        isVerified: true,
        phone: "01711000015",
        bio: "ইন্ডাস্ট্রিয়াল ও হোম ইলেকট্রিক্যাল স্পেশালিস্ট।",
        distance: 1.1,
      ),
      ProviderModel(
        id: 16,
        name: "জাকির হোসেন",
        category: "AC মেরামত",
        rating: 4.6,
        reviewCount: 56,
        isOnline: true,
        isVerified: true,
        phone: "01711000016",
        bio: "এসি ও ফ্রিজ মেরামত টেকনিশিয়ান।",
        distance: 2.7,
      ),
    ];
    _allProviders.addAll(defaults);
  }

  Future<void> fetchFromBackend({double? lat, double? lng}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final backendList = await ApiService.getProviders(lat: lat, lng: lng);
      if (backendList.isNotEmpty) {
        // Merge or prioritize backend providers
        for (final p in backendList) {
          final idx = _allProviders.indexWhere((x) => x.id == p.id);
          if (idx != -1) {
            _allProviders[idx] = p;
          } else {
            _allProviders.insert(0, p);
          }
        }
      }
    } catch (_) {
      // Gracefully continue with rich local dataset
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ProviderModel> getFilteredProviders({String? category, String? sort}) {
    final cat = category ?? _selectedCategory;
    final s = sort ?? _currentSort;

    var list = _allProviders.toList();

    if (cat != null && cat.isNotEmpty && cat != 'সব' && cat != 'সব ধরন') {
      list = list.where((k) {
        final c = k.category.toLowerCase();
        final target = cat.toLowerCase();
        if (target.contains('গ্যাস') && c.contains('গ্যাস')) return true;
        if (target.contains('ইলেকট্রিক') && c.contains('ইলেকট্রিক')) return true;
        if (target.contains('প্লাম্ব') && c.contains('প্লাম্ব')) return true;
        if ((target.contains('কাঠ') || target.contains('ছুতার')) &&
            (c.contains('কাঠ') || c.contains('ছুতার'))) return true;
        if (target.contains('ac') || target.contains('এসি')) {
          return c.contains('ac') || c.contains('এসি');
        }
        if (target.contains('রং') && c.contains('রং')) return true;
        return c.contains(target);
      }).toList();
    }

    if (s == 'status') {
      list.sort((a, b) {
        if (a.isOnline != b.isOnline) {
          return b.isOnline ? 1 : -1;
        }
        return a.distance.compareTo(b.distance);
      });
    } else if (s == 'distance') {
      list.sort((a, b) => a.distance.compareTo(b.distance));
    }

    return list;
  }

  void setCategoryFilter(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSort(String sort) {
    _currentSort = sort;
    notifyListeners();
  }

  // --- 1-on-1 Direct Chat Methods ---

  List<DirectChatMessage> getChatHistory(int karigorId, String karigorName) {
    if (!_directChats.containsKey(karigorId)) {
      _directChats[karigorId] = [
        DirectChatMessage(
          isUser: false,
          text: "আসসালামু আলাইকুম, আমি $karigorName। আপনার কাজে সাহায্য করতে পারলে খুশি হবো। কী সমস্যা হয়েছে বলুন।",
        )
      ];
    }
    return _directChats[karigorId]!;
  }

  void sendDirectMessage(int karigorId, String text) {
    if (text.trim().isEmpty) return;
    if (!_directChats.containsKey(karigorId)) {
      _directChats[karigorId] = [];
    }
    _directChats[karigorId]!.add(DirectChatMessage(isUser: true, text: text.trim()));
    notifyListeners();

    // Realistic automated reply after brief delay
    const replies = [
      "জি, বুঝেছি। আমি প্রায় ৩০-৪০ মিনিটের মধ্যে পৌঁছাতে পারবো।",
      "ঠিক আছে, ঠিকানাটা একটু বিস্তারিত পাঠান।",
      "আনুমানিক খরচ কাজের ধরন দেখে বলতে পারবো, তবে বাজেটের কাছাকাছিই হবে ইনশাআল্লাহ।",
      "আচ্ছা, আমি এখনই রওনা দিচ্ছি।"
    ];
    Future.delayed(const Duration(milliseconds: 900), () {
      final reply = replies[DateTime.now().microsecond % replies.length];
      _directChats[karigorId]?.add(DirectChatMessage(isUser: false, text: reply));
      notifyListeners();
    });
  }

  // --- Sent Job Requests Methods ---

  Future<bool> sendRequest({
    required int? seekerId,
    required ProviderModel? karigor,
    required String description,
    required String location,
    required double amount,
  }) async {
    final newId = DateTime.now().millisecondsSinceEpoch % 10000;
    final req = SentJobRequest(
      id: newId,
      karigor: karigor,
      description: description,
      location: location,
      amount: amount,
      timeAgo: 'এইমাত্র',
    );
    _sentRequests.insert(0, req);
    notifyListeners();

    if (seekerId != null && karigor != null) {
      try {
        await ApiService.sendJobRequest(
          seekerId: seekerId,
          karigorId: karigor.id,
          description: description,
          location: location,
          amount: amount,
        );
      } catch (_) {
        // Local state already updated
      }
    }
    return true;
  }

  void deleteRequest(int id) {
    _sentRequests.removeWhere((r) => r.id == id);
    notifyListeners();
  }
}
