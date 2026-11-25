import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_router.dart';
import 'services/auth_provider.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const KarigorKhojApp());
}

class KarigorKhojApp extends StatelessWidget {
  const KarigorKhojApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..loadSavedUser(),
      child: MaterialApp(
        title: 'কারিগর খোঁজ',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: '/splash',
      ),
    );
  }
}
