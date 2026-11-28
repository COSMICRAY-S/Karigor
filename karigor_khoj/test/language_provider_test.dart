import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:karigor_khoj/services/language_provider.dart';
import 'package:karigor_khoj/services/app_translations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LanguageProvider and AppTranslations Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initial language is English by default', () async {
      final provider = LanguageProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(provider.currentLanguage, 'en');
      expect(provider.isEnglish, isTrue);
      expect(provider.isBengali, isFalse);
      expect(provider.t('app_name'), 'Karigor Khoj');
    });

    test('Can switch language to Bangla and back', () async {
      final provider = LanguageProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      await provider.setLanguage('bn');
      expect(provider.currentLanguage, 'bn');
      expect(provider.isBengali, isTrue);
      expect(provider.t('app_name'), 'কারিগর খোঁজ');

      await provider.toggleLanguage();
      expect(provider.currentLanguage, 'en');
      expect(provider.isEnglish, isTrue);
    });

    test('Saves and restores language preference for individual users', () async {
      final provider = LanguageProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      // User 1 logs in and chooses Bangla
      await provider.onUserChanged(101);
      await provider.setLanguage('bn');
      expect(provider.currentLanguage, 'bn');

      // User 2 logs in on same device and chooses English
      await provider.onUserChanged(202);
      await provider.setLanguage('en');
      expect(provider.currentLanguage, 'en');

      // User 1 logs back in, their preference (bn) must be restored!
      await provider.onUserChanged(101);
      expect(provider.currentLanguage, 'bn');

      // User 2 logs back in, their preference (en) must be restored!
      await provider.onUserChanged(202);
      expect(provider.currentLanguage, 'en');
    });

    test('AppTranslations translates required section keys', () {
      expect(AppTranslations.get('app_name', 'en'), 'Karigor Khoj');
      expect(AppTranslations.get('app_name', 'bn'), 'কারিগর খোঁজ');

      expect(AppTranslations.get('seeker_card_title', 'en'), 'I Need a Service');
      expect(AppTranslations.get('seeker_card_title', 'bn'), 'আমি সেবা খুঁজছি');

      expect(AppTranslations.get('login_btn', 'en'), 'Login');
      expect(AppTranslations.get('login_btn', 'bn'), 'লগইন করুন');

      expect(AppTranslations.get('settings_title', 'en'), 'App Settings');
      expect(AppTranslations.get('settings_title', 'bn'), 'অ্যাপ সেটিংস');

      expect(AppTranslations.translateCategory('প্লাম্বার', 'en'), 'Plumber');
      expect(AppTranslations.translateCategory('Electrician', 'bn'), 'ইলেকট্রিশিয়ান');

      expect(AppTranslations.translateStatus('pending', 'en'), 'Pending');
      expect(AppTranslations.translateStatus('pending', 'bn'), 'অপেক্ষমান');
    });
  });
}
