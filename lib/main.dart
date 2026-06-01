import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // =========================
  // SUPABASE INIT
  // =========================
  await Supabase.initialize(
    url: 'https://xixhmksncknsyvwzywkr.supabase.co',
    anonKey: 'sb_publishable_yyJTg9_F0wOLcxdZAoczYQ_bfeB1kS6',
  );

  runApp(const SudanRx());
}

class SudanRx extends StatelessWidget {
  const SudanRx({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SudanRx',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.classic,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
