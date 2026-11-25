import 'dart:math';
import '../models/provider_model.dart';

class AiCategoryIntent {
  final List<String> keys;
  final String cat;
  final String label;
  final String icon;

  const AiCategoryIntent({
    required this.keys,
    required this.cat,
    required this.label,
    required this.icon,
  });
}

class AiChatBubble {
  final String text;
  final bool isUser;
  final bool isReasoning;
  final String? thinkTag;
  final List<ProviderModel>? matchedProviders;
  final String? tip;

  AiChatBubble({
    required this.text,
    required this.isUser,
    this.isReasoning = false,
    this.thinkTag,
    this.matchedProviders,
    this.tip,
  });
}

class KarigorAiService {
  static const List<AiCategoryIntent> intentMap = [
    AiCategoryIntent(
      keys: ['গ্যাস', 'gas', 'gyas', 'gass', 'chulha', 'চুলা', 'burner', 'বার্নার'],
      cat: 'gas',
      label: 'গ্যাস লাইন',
      icon: '🔥',
    ),
    AiCategoryIntent(
      keys: [
        'প্লাম্বার',
        'প্লাম্বিং',
        'প্লামবার',
        'পানি',
        'কল',
        'পাইপ',
        'লিক',
        'leak',
        'tap',
        'plumber',
        'plumbing',
        'পানির লাইন',
        'টয়লেট',
        'বাথরুম',
        'washroom',
        'commode',
        'কমোড',
        'ট্যাপ'
      ],
      cat: 'plumb',
      label: 'প্লাম্বিং',
      icon: '🚰',
    ),
    AiCategoryIntent(
      keys: [
        'লাইট',
        'ইলেকট্রিক',
        'ইলেক্ট্রিক',
        'সুইচ',
        'বৈদ্যুতিক',
        'কারেন্ট',
        'ফ্যান',
        'মিটার',
        'electric',
        'electrician',
        'current',
        'switch',
        'fan',
        'wiring',
        'ওয়্যারিং',
        'শর্ট সার্কিট',
        'short circuit',
        'bijli',
        'বিজলি'
      ],
      cat: 'electric',
      label: 'ইলেকট্রিক্যাল',
      icon: '🔌',
    ),
    AiCategoryIntent(
      keys: [
        'কাঠ',
        'দরজা',
        'জানালা',
        'আলমারি',
        'ফার্নিচার',
        'carpenter',
        'furniture',
        'door',
        'window',
        'wood',
        'কাঠমিস্ত্রি',
        'sofa',
        'সোফা',
        'খাট',
        'bed'
      ],
      cat: 'wood',
      label: 'কাঠের কাজ',
      icon: '🪚',
    ),
    AiCategoryIntent(
      keys: [
        'এসি',
        'ac',
        'acer',
        'ফ্রিজ',
        'রেফ্রিজারেটর',
        'fridge',
        'freeze',
        'cooling',
        'কুলিং',
        'refrigerator',
        'air condition'
      ],
      cat: 'ac',
      label: 'এসি/ফ্রিজ',
      icon: '❄️',
    ),
    AiCategoryIntent(
      keys: ['রং', 'পেইন্ট', 'রঙ', 'paint', 'painter', 'painting', 'color', 'কালার'],
      cat: 'paint',
      label: 'রং এর কাজ',
      icon: '🎨',
    ),
  ];

  static const Map<String, List<String>> categoryTips = {
    'gas': [
      "গ্যাসের গন্ধ পেলে প্রথমেই চুলা বন্ধ করে মেইন ভালভ বন্ধ করে রাখুন, আর জানালা খুলে ঘর বাতাস চলাচল করতে দিন — কারিগর আসার আগ পর্যন্ত এটা জরুরি।",
      "গ্যাস লিকেজের সময় ঘরে কোনো ম্যাচ বা লাইটার জ্বালাবেন না, ইলেকট্রিক সুইচও অন-অফ করবেন না — স্পার্ক থেকে বিপদ হতে পারে।",
      "যদি লাইন থেকে হিসহিস শব্দ হয় তাহলে এটা বড় লিক হতে পারে — কারিগর আসার আগে সিলিন্ডার/মেইন লাইন বন্ধ রাখাই নিরাপদ।"
    ],
    'plumb': [
      "কল বা পাইপ থেকে পানি পড়লে প্রথমে মেইন ভালভ বন্ধ করে দিন, তাহলে পানির অপচয় ও ঘরের ক্ষতি দুটোই কম হবে।",
      "কমোড আটকে গেলে অতিরিক্ত পানি না ঢেলে একটু অপেক্ষা করুন — কারিগর প্রয়োজনীয় টুল নিয়ে আসবে।",
      "লিকের জায়গায় সাময়িকভাবে কাপড় বা টেপ পেঁচিয়ে রাখতে পারেন, তবে এটা স্থায়ী সমাধান না — কারিগর এসে ঠিক করে দিলে ভালো।"
    ],
    'electric': [
      "শর্ট সার্কিটের সন্দেহ হলে সাথে সাথে মেইন সুইচ/মেইন ব্রেকার বন্ধ করে দিন, এতে আগুন লাগার ঝুঁকি কমে যায়।",
      "সুইচ বোর্ড থেকে স্পার্ক বা পোড়া গন্ধ পেলে ওই সার্কিটটা বন্ধ রাখুন এবং কাছাকাছি জিনিসপত্র সরিয়ে ফেলুন।",
      "ভেজা হাতে কখনো সুইচ বা প্লাগ স্পর্শ করবেন না — কারিগর না আসা পর্যন্ত এই সতর্কতা মেনে চলুন।"
    ],
    'wood': [
      "দরজা/জানালা আটকে গেলে জোর করে টানাটানি না করে সমস্যাটা ছবি তুলে রাখুন, কারিগরকে দেখাতে সুবিধা হবে।",
      "আলমারি বা ফার্নিচারের কোনো অংশ ভাঙা থাকলে ছোট স্ক্রু/নাট আলাদা করে রাখুন, হারিয়ে গেলে মেরামত কঠিন হয়ে যায়।"
    ],
    'ac': [
      "এসি থেকে পানি পড়লে সাধারণত ড্রেন পাইপ বন্ধ হয়ে যাওয়ার কারণে হয় — টেকনিশিয়ান আসা পর্যন্ত এসি বন্ধ রাখতে পারেন।",
      "ফ্রিজ ঠান্ডা না হলে প্রথমে পিছনের কনডেন্সার কয়েল আর দরজার সিল চেক করুন, ময়লা জমে থাকলে ঠান্ডা কম হয়।"
    ],
    'paint': [
      "রং করার আগে দেয়ালের স্যাঁতসেঁতে ভাব বা ফাটল থাকলে সেটা কারিগরকে জানিয়ে দিন, নাহলে রং বেশিদিন টিকবে না।"
    ]
  };

  static const List<String> ackPhrases = [
    "আচ্ছা বুঝলাম",
    "ঠিক আছে, দেখছি",
    "ওকে, ধন্যবাদ জানানোর জন্য",
    "বুঝতে পেরেছি সমস্যাটা",
    "আচ্ছা, এই ব্যাপারে সাহায্য করতে পারবো",
  ];

  static const List<String> searchPhrases = [
    "আপনার আশেপাশে কারা এখন কাজের জন্য রেডি আছেন খুঁজে দেখছি...",
    "এলাকার অনলাইন কারিগরদের লিস্ট চেক করছি...",
    "কাছাকাছি কে কে এখন ফ্রি আছেন সেটা বের করছি...",
    "এক সেকেন্ড, নিকটস্থ কারিগরদের অবস্থা দেখে নিচ্ছি...",
  ];

  static final Random _rng = Random();

  static String pick(List<String> list) => list[_rng.nextInt(list.length)];

  static int? extractBudget(String text) {
    final enRegex = RegExp(r'(\d{2,6})\s*(টাকা|taka|tk|৳)?', caseSensitive: false);
    final match = enRegex.firstMatch(text);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '');
    }

    const bnDigits = {
      '০': '0',
      '১': '1',
      '২': '2',
      '৩': '3',
      '৪': '4',
      '৫': '5',
      '৬': '6',
      '৭': '7',
      '৮': '8',
      '৯': '9'
    };
    final bnRegex = RegExp(r'([০-৯]{2,6})');
    final bnMatch = bnRegex.firstMatch(text);
    if (bnMatch != null) {
      final str = bnMatch.group(1) ?? '';
      final converted = str.split('').map((c) => bnDigits[c] ?? '').join();
      return int.tryParse(converted);
    }
    return null;
  }

  static AiCategoryIntent? detectIntent(String text) {
    final lower = text.toLowerCase();
    for (final item in intentMap) {
      if (item.keys.any((k) => lower.contains(k.trim().toLowerCase()))) {
        return item;
      }
    }
    return null;
  }
}
