import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_router.dart';
import 'services/auth_provider.dart';
import 'services/language_provider.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KarigorKhojApp());
}

class KarigorKhojApp extends StatelessWidget {
  const KarigorKhojApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProxyProvider<LanguageProvider, AuthProvider>(
          create: (ctx) => AuthProvider()..loadSavedUser(),
          update: (ctx, lang, auth) {
            auth ??= AuthProvider()..loadSavedUser();
            auth.attachLanguageProvider(lang);
            return auth;
          },
        ),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, lang, _) {
          return MaterialApp(
            title: lang.t('app_name'),
            locale: lang.currentLocale,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: '/splash',
          );
        },
      ),
    );
  }
}
