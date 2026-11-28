class AppTranslations {
  static const Map<String, Map<String, String>> _values = {
    'en': {
      // General & Branding
      'app_name': 'Karigor Khoj',
      'tagline': 'Trusted local artisans & gig workers in one tap',
      'language': 'Language',
      'english': 'English',
      'bangla': 'বাংলা',
      'settings': 'Settings',
      'app_settings': 'App Settings',
      'save': 'Save',
      'cancel': 'Cancel',
      'back': 'Back',
      'error': 'Error',
      'success': 'Success',
      'close': 'Close',

      // Role Select & Sign In Screen
      'role_select_title': 'Choose Your Role',
      'seeker_card_title': 'I Need a Service',
      'seeker_card_subtitle': 'Looking for a plumber, electrician, carpenter, or other artisan',
      'karigor_card_title': 'I am a Karigor',
      'karigor_card_subtitle': 'Want to offer skills and find work in my area',
      'email_phone_hint': 'Email or mobile number',
      'password_hint': 'Password',
      'sign_in_btn': 'Sign In',
      'prototype_note': 'Prototype — Sign in directly or register below',
      'create_account_btn': 'Create New Account',
      'forgot_password_btn': 'Forgot Password?',
      'enter_credentials_msg': 'Please enter mobile number/email and password',

      // Auth Screens (Login / Register / Forgot Password)
      'karigor_login_title': 'Karigor Login',
      'seeker_login_title': 'Service Seeker Login',
      'karigor_login_heading': 'Login as Karigor',
      'seeker_login_heading': 'Login as Service Seeker',
      'phone_label': 'Mobile Number',
      'phone_hint': '01XXXXXXXXX',
      'password_label': 'Password',
      'login_btn': 'Login',
      'register_prompt': 'New here? Register now',
      'already_have_account': 'Already have an account? Login',
      'full_name_label': 'Full Name',
      'full_name_hint': 'Enter your full name',
      'email_label': 'Email (Optional)',
      'email_hint': 'name@example.com',
      'register_title': 'Register',
      'karigor_reg_heading': 'Register as Karigor',
      'seeker_reg_heading': 'Register as Service Seeker',
      'register_btn': 'Register',
      'password_min_length': 'Password must be at least 4 characters',
      'fill_all_fields': 'Please fill all required fields',
      'password_recovery_title': 'Password Recovery',
      'recovery_instruction': 'Enter your registered email and new password to reset.',
      'new_password_label': 'New Password',
      'reset_password_btn': 'Reset Password',
      'password_reset_success': 'Password changed successfully. Please login.',

      // Navigation Items
      'nav_home': 'Home',
      'nav_requests': 'Requests',
      'nav_chat': 'Messages',
      'nav_profile': 'Profile',
      'nav_dashboard': 'Dashboard',
      'nav_jobs': 'Jobs',
      'nav_history': 'History',
      'nav_rating': 'Ratings',

      // Seeker Home Screen
      'your_location': 'Your Location',
      'default_location': 'Mirpur 10, Dhaka',
      'welcome_greeting': 'Welcome',
      'search_placeholder': 'Search karigor (e.g. Plumber, AC repair)...',
      'ai_banner_title': 'Tell the AI Assistant your issue',
      'ai_banner_subtitle': 'Ask in English or Bangla for instant recommendations',
      'popular_services': 'Popular Services',
      'view_all': 'View All',
      'top_rated_karigors': 'Top Rated Karigors',
      'nearby_karigors': 'Nearby Karigors',
      'verified': 'Verified',
      'request_service_btn': 'Request Service',
      'call': 'Call',
      'message': 'Message',
      'book_now': 'Book Now',
      'reviews': 'Reviews',
      'experience': 'Experience',
      'years': 'yrs',
      'km_away': 'km away',
      'online': 'Online',
      'offline': 'Offline',

      // Categories
      'cat_all': 'All',
      'cat_gas': 'Gas Line',
      'cat_electrician': 'Electrician',
      'cat_plumber': 'Plumber',
      'cat_carpenter': 'Carpenter',
      'cat_ac': 'AC & Fridge Repair',
      'cat_painter': 'Painter',
      'cat_tailor': 'Tailor',
      'cat_mechanic': 'Auto Mechanic',
      'cat_appliances': 'Home Appliances',
      'cat_mason': 'Mason',
      'cat_welder': 'Welder',
      'cat_cleaning': 'Cleaning',

      // Seeker Requests Tab
      'my_requests_title': 'My Service Requests',
      'no_requests_found': 'No service requests yet',
      'no_requests_sub': 'Choose a karigor from the home screen to send a request.',
      'status_pending': 'Pending',
      'status_accepted': 'Accepted',
      'status_completed': 'Completed',
      'status_cancelled': 'Cancelled',

      // Seeker Profile Tab
      'profile_title': 'Profile',
      'notifications': 'Notifications',
      'help_support': 'Help & Support',
      'logout': 'Logout',
      'logout_confirm_msg': 'Are you sure you want to log out?',

      // Karigor Home & Dashboard
      'karigor_dashboard': 'Karigor Dashboard',
      'status_available': 'Available for new jobs',
      'status_unavailable': 'Currently unavailable',
      'toggle_online': 'Online',
      'toggle_offline': 'Offline',
      'stat_earnings': "Today's Earnings",
      'stat_completed': 'Completed Jobs',
      'stat_rating': 'Rating',
      'new_requests_section': 'New Job Requests',
      'no_new_requests': 'No new incoming requests right now',
      'accept_btn': 'Accept',
      'decline_btn': 'Decline',
      'mark_complete_btn': 'Mark Complete',
      'edit_profile': 'Edit Profile',
      'select_profession': 'Profession / Category',
      'bio_label': 'Short Bio',
      'update_profile_btn': 'Update Profile',
      'update_gps_btn': '📍 Update Current GPS Location',
      'job_history_title': 'Job History',
      'ratings_reviews_title': 'Ratings & Reviews',

      // Settings Screen
      'settings_title': 'App Settings',
      'language_section_title': 'Language Preferences',
      'language_section_subtitle': 'Choose English or Bangla. This setting is saved individually for your account.',
      'language_english_label': 'English (Default)',
      'language_bangla_label': 'বাংলা (Bangla)',
      'saved_for_user': 'Saved for user',
      'guest_user': 'Guest (Not signed in)',
      'general_section_title': 'General',
      'push_notifications': 'Push Notifications',
      'push_notifications_sub': 'Receive instant job alerts and updates',
      'account_section_title': 'Account',
      'logged_in_as': 'Logged in as',
      'user_role': 'Role',
      'about_section_title': 'About',
      'about_app_name': 'Karigor Khoj Bangladesh',
      'app_version': 'Version 1.0.0+1',
      'app_desc': 'Local service provider and gig worker directory connecting service seekers with skilled workers.',
      'language_updated_msg': 'Language updated to English',
    },
    'bn': {
      // General & Branding
      'app_name': 'কারিগর খোঁজ',
      'tagline': 'আপনার এলাকার বিশ্বস্ত কারিগর, এক ট্যাপে',
      'language': 'ভাষা',
      'english': 'English',
      'bangla': 'বাংলা',
      'settings': 'সেটিংস',
      'app_settings': 'অ্যাপ সেটিংস',
      'save': 'সংরক্ষণ',
      'cancel': 'বাতিল',
      'back': 'পেছনে',
      'error': 'ত্রুটি',
      'success': 'সফল',
      'close': 'বন্ধ',

      // Role Select & Sign In Screen
      'role_select_title': 'ভূমিকা নির্বাচন করুন',
      'seeker_card_title': 'আমি সেবা খুঁজছি',
      'seeker_card_subtitle': 'প্লাম্বার, ইলেকট্রিশিয়ান বা অন্য কারিগর দরকার',
      'karigor_card_title': 'আমি একজন কারিগর',
      'karigor_card_subtitle': 'আমার দক্ষতা দিয়ে অন্যদের সাহায্য করতে চাই',
      'email_phone_hint': 'ইমেইল অথবা মোবাইল নম্বর',
      'password_hint': 'পাসওয়ার্ড',
      'sign_in_btn': 'প্রবেশ করুন',
      'prototype_note': 'প্রোটোটাইপ — সরাসরি প্রবেশ করুন অথবা নিচে নিবন্ধন করুন',
      'create_account_btn': 'নতুন অ্যাকাউন্ট তৈরি করুন',
      'forgot_password_btn': 'পাসওয়ার্ড ভুলে গেছেন?',
      'enter_credentials_msg': 'মোবাইল নম্বর/ইমেইল ও পাসওয়ার্ড লিখুন',

      // Auth Screens (Login / Register / Forgot Password)
      'karigor_login_title': 'কারিগর লগইন',
      'seeker_login_title': 'সেবা গ্রহণকারী লগইন',
      'karigor_login_heading': 'কারিগর হিসেবে লগইন',
      'seeker_login_heading': 'সেবা গ্রহণকারী হিসেবে লগইন',
      'phone_label': 'মোবাইল নম্বর',
      'phone_hint': '01XXXXXXXXX',
      'password_label': 'পাসওয়ার্ড',
      'login_btn': 'লগইন করুন',
      'register_prompt': 'নতুন? এখানে নিবন্ধন করুন',
      'already_have_account': 'ইতিমধ্যে অ্যাকাউন্ট আছে? লগইন করুন',
      'full_name_label': 'পূর্ণ নাম',
      'full_name_hint': 'আপনার পুরো নাম লিখুন',
      'email_label': 'ইমেইল (ঐচ্ছিক)',
      'email_hint': 'name@example.com',
      'register_title': 'নিবন্ধন করুন',
      'karigor_reg_heading': 'কারিগর হিসেবে নিবন্ধন করুন',
      'seeker_reg_heading': 'সেবা গ্রহণকারী হিসেবে নিবন্ধন করুন',
      'register_btn': 'নিবন্ধন করুন',
      'password_min_length': 'পাসওয়ার্ড কমপক্ষে ৪ অক্ষরের হতে হবে',
      'fill_all_fields': 'সবগুলো প্রয়োজনীয় তথ্য পূরণ করুন',
      'password_recovery_title': 'পাসওয়ার্ড পুনরুদ্ধার',
      'recovery_instruction': 'আপনার নিবন্ধিত ইমেইল ও নতুন পাসওয়ার্ড দিয়ে রিসেট করুন।',
      'new_password_label': 'নতুন পাসওয়ার্ড',
      'reset_password_btn': 'পাসওয়ার্ড পরিবর্তন করুন',
      'password_reset_success': 'পাসওয়ার্ড সফলভাবে পরিবর্তন করা হয়েছে। লগইন করুন।',

      // Navigation Items
      'nav_home': 'হোম',
      'nav_requests': 'অনুরোধ',
      'nav_chat': 'মেসেজ',
      'nav_profile': 'প্রোফাইল',
      'nav_dashboard': 'ড্যাশবোর্ড',
      'nav_jobs': 'কাজসমূহ',
      'nav_history': 'ইতিহাস',
      'nav_rating': 'রেটিং',

      // Seeker Home Screen
      'your_location': 'আপনার অবস্থান',
      'default_location': 'মিরপুর ১০, ঢাকা',
      'welcome_greeting': 'স্বাগতম',
      'search_placeholder': 'কারিগর খুঁজুন (উদা: প্লাম্বার, এসি রিপেয়ার)...',
      'ai_banner_title': 'AI সহকারীকে বলুন আপনার সমস্যা',
      'ai_banner_subtitle': 'বাংলা বা ইংরেজিতে লিখুন, সরাসরি সমাধান মিলবে',
      'popular_services': 'জনপ্রিয় সেবা',
      'view_all': 'সব দেখুন',
      'top_rated_karigors': 'শীর্ষ রেটেড কারিগর',
      'nearby_karigors': 'কাছাকাছি কারিগর',
      'verified': 'যাচাইকৃত',
      'request_service_btn': 'সেবা চান',
      'call': 'কল',
      'message': 'মেসেজ',
      'book_now': 'বুক করুন',
      'reviews': 'রিভিউ',
      'experience': 'অভিজ্ঞতা',
      'years': 'বছর',
      'km_away': 'কিমি দূরে',
      'online': 'অনলাইন',
      'offline': 'অফলাইন',

      // Categories
      'cat_all': 'সব ধরন',
      'cat_gas': 'গ্যাস লাইন',
      'cat_electrician': 'ইলেকট্রিশিয়ান',
      'cat_plumber': 'প্লাম্বার',
      'cat_carpenter': 'কাঠমিস্ত্রি',
      'cat_ac': 'এসি ও ফ্রিজ',
      'cat_painter': 'রং মিস্ত্রি',
      'cat_tailor': 'দর্জি',
      'cat_mechanic': 'গাড়ি মেকানিক',
      'cat_appliances': 'গৃহস্থালি যন্ত্রপাতি',
      'cat_mason': 'রাজমিস্ত্রি',
      'cat_welder': 'ওয়েল্ডার',
      'cat_cleaning': 'ক্লিনিং',

      // Seeker Requests Tab
      'my_requests_title': 'আমার অনুরোধসমূহ',
      'no_requests_found': 'কোনো অনুরোধ নেই',
      'no_requests_sub': 'নতুন অনুরোধ তৈরি করতে হোম স্ক্রিন থেকে কারিগর বেছে নিন।',
      'status_pending': 'অপেক্ষমান',
      'status_accepted': 'গৃহীত',
      'status_completed': 'সম্পন্ন',
      'status_cancelled': 'বাতিল',

      // Seeker Profile Tab
      'profile_title': 'প্রোফাইল',
      'notifications': 'নোটিফিকেশন',
      'help_support': 'সাহায্য ও সহায়তা',
      'logout': 'লগআউট',
      'logout_confirm_msg': 'আপনি কি নিশ্চিতভাবে লগআউট করতে চান?',

      // Karigor Home & Dashboard
      'karigor_dashboard': 'কারিগর ড্যাশবোর্ড',
      'status_available': 'বর্তমানে নতুন কাজের জন্য প্রস্তুত',
      'status_unavailable': 'বর্তমানে অনুপলব্ধ',
      'toggle_online': 'অনলাইন',
      'toggle_offline': 'অফলাইন',
      'stat_earnings': 'আজকের আয়',
      'stat_completed': 'সম্পন্ন কাজ',
      'stat_rating': 'রেটিং',
      'new_requests_section': 'নতুন কাজের অনুরোধ',
      'no_new_requests': 'বর্তমানে কোনো নতুন কাজের অনুরোধ নেই',
      'accept_btn': 'গ্রহণ করুন',
      'decline_btn': 'প্রত্যাখ্যান',
      'mark_complete_btn': 'কাজ সম্পন্ন',
      'edit_profile': 'প্রোফাইল সম্পাদনা',
      'select_profession': 'পেশা / ক্যাটাগরি',
      'bio_label': 'সংক্ষিপ্ত বিবরণ (Bio)',
      'update_profile_btn': 'প্রোফাইল আপডেট করুন',
      'update_gps_btn': '📍 বর্তমান জিপিএস অবস্থান আপডেট করুন',
      'job_history_title': 'কাজের ইতিহাস',
      'ratings_reviews_title': 'রেটিং ও রিভিউ',

      // Settings Screen
      'settings_title': 'অ্যাপ সেটিংস',
      'language_section_title': 'ভাষা নির্বাচন (Language)',
      'language_section_subtitle': 'ইংরেজি বা বাংলা নির্বাচন করুন। এই পছন্দটি আপনার অ্যাকাউন্টে সংরক্ষিত থাকবে।',
      'language_english_label': 'English (ইংরেজি)',
      'language_bangla_label': 'বাংলা (Bangla)',
      'saved_for_user': 'সংরক্ষিত ব্যবহারকারী',
      'guest_user': 'গেস্ট (লগইন করা নেই)',
      'general_section_title': 'সাধারণ',
      'push_notifications': 'পুশ নোটিফিকেশন',
      'push_notifications_sub': 'কাজের অ্যালার্ট ও আপডেট সরাসরি পান',
      'account_section_title': 'অ্যাকাউন্ট',
      'logged_in_as': 'লগইন আছেন',
      'user_role': 'ভূমিকা',
      'about_section_title': 'সম্পর্কে',
      'about_app_name': 'কারিগর খোঁজ বাংলাদেশ',
      'app_version': 'ভার্সন ১.০.০+১',
      'app_desc': 'স্থানীয় দক্ষ কারিগর ও সেবা গ্রহণকারীদের সংযোগকারী ডিজিটাল প্ল্যাটফর্ম।',
      'language_updated_msg': 'ভাষা সফলভাবে বাংলায় পরিবর্তন করা হয়েছে',
    },
  };

  static String get(String key, String langCode) {
    final lang = _values.containsKey(langCode) ? langCode : 'en';
    return _values[lang]?[key] ?? _values['en']?[key] ?? key;
  }

  static String translateCategory(String categoryName, String langCode) {
    final lower = categoryName.toLowerCase().trim();
    final isBn = langCode == 'bn';

    if (lower.contains('গ্যাস') || lower.contains('gas')) {
      return isBn ? 'গ্যাস লাইন' : 'Gas Line';
    }
    if (lower.contains('ইলেক') || lower.contains('electr')) {
      return isBn ? 'ইলেকট্রিশিয়ান' : 'Electrician';
    }
    if (lower.contains('প্লাম্ব') || lower.contains('plumb')) {
      return isBn ? 'প্লাম্বার' : 'Plumber';
    }
    if (lower.contains('কাঠ') || lower.contains('ছুতার') || lower.contains('carpent')) {
      return isBn ? 'কাঠমিস্ত্রি' : 'Carpenter';
    }
    if (lower.contains('এসি') || lower.contains('ac') || lower.contains('ফ্রিজ')) {
      return isBn ? 'এসি ও ফ্রিজ' : 'AC & Fridge';
    }
    if (lower.contains('রং') || lower.contains('paint')) {
      return isBn ? 'রং মিস্ত্রি' : 'Painter';
    }
    if (lower.contains('দর্জি') || lower.contains('tailor')) {
      return isBn ? 'দর্জি' : 'Tailor';
    }
    if (lower.contains('গাড়ি') || lower.contains('মেকানিক') || lower.contains('mechanic')) {
      return isBn ? 'গাড়ি মেকানিক' : 'Auto Mechanic';
    }
    if (lower.contains('যন্ত্র') || lower.contains('appliance')) {
      return isBn ? 'গৃহস্থালি যন্ত্রপাতি' : 'Home Appliances';
    }
    if (lower.contains('রাজ') || lower.contains('mason')) {
      return isBn ? 'রাজমিস্ত্রি' : 'Mason';
    }
    if (lower.contains('ওয়েল্ড') || lower.contains('weld')) {
      return isBn ? 'ওয়েল্ডার' : 'Welder';
    }
    return categoryName;
  }

  static String translateStatus(String status, String langCode) {
    final isBn = langCode == 'bn';
    switch (status.toLowerCase()) {
      case 'pending':
        return isBn ? 'অপেক্ষমান' : 'Pending';
      case 'accepted':
        return isBn ? 'গৃহীত' : 'Accepted';
      case 'completed':
        return isBn ? 'সম্পন্ন' : 'Completed';
      case 'cancelled':
        return isBn ? 'বাতিল' : 'Cancelled';
      default:
        return status;
    }
  }
}
