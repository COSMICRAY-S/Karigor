import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/role_select_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/seeker/seeker_home_screen.dart';
import 'screens/seeker/search_screen.dart';
import 'screens/seeker/provider_detail_screen.dart';
import 'screens/seeker/all_karigors_screen.dart';
import 'screens/seeker/karigor_ai_chat_screen.dart';
import 'screens/karigor/karigor_home_screen.dart';
import 'screens/karigor/karigor_profile_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/role-select':
        return MaterialPageRoute(builder: (_) => const RoleSelectScreen());
      case '/login':
        final role = settings.arguments as String? ?? 'seeker';
        return MaterialPageRoute(builder: (_) => LoginScreen(role: role));
      case '/forgot-password':
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case '/register':
        final role = settings.arguments as String? ?? 'seeker';
        return MaterialPageRoute(builder: (_) => RegisterScreen(role: role));
      case '/seeker-home':
        return MaterialPageRoute(builder: (_) => const SeekerHomeScreen());
      case '/search':
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case '/all-karigors':
        final cat = settings.arguments as String?;
        return MaterialPageRoute(builder: (_) => AllKarigorsScreen(initialCategory: cat));
      case '/ai-chat':
        return MaterialPageRoute(builder: (_) => const KarigorAiChatScreen());
      case '/provider-detail':
        final providerId = settings.arguments as int? ?? 0;
        return MaterialPageRoute(
            builder: (_) => ProviderDetailScreen(providerId: providerId));
      case '/karigor-home':
        return MaterialPageRoute(builder: (_) => const KarigorHomeScreen());
      case '/karigor-profile':
        return MaterialPageRoute(
            builder: (_) => const KarigorProfileScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
