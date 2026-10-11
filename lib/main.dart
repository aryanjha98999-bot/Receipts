import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: Config.supabaseUrl, anonKey: Config.supabaseAnonKey);
  runApp(const ReceiptsApp());
}

class ReceiptsApp extends StatelessWidget {
  const ReceiptsApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(title: 'Receipts', debugShowCheckedModeBanner: false, theme: buildTheme(), home: const AuthGate());
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) => StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (_, __) {
          final s = Supabase.instance.client.auth.currentSession;
          return s == null ? const AuthScreen() : HomeScreen(key: ValueKey(s.user.id));
        },
      );
}