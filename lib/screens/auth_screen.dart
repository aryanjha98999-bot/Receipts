import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import '../widgets/fun.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final email = TextEditingController(), pass = TextEditingController();
  final emailF = FocusNode(), passF = FocusNode();
  bool signup = false, busy = false, good = false;
  int shakes = 0;
  String? msg;

  @override
  void initState() {
    super.initState();
    emailF.addListener(_refresh);
    passF.addListener(_refresh);
  }

  void _refresh() { if (mounted) setState(() {}); }

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    emailF.dispose();
    passF.dispose();
    super.dispose();
  }

  // The mascot reacts to what you're doing.
  String get face => busy ? '🤔' : (msg != null && !good) ? '😬' : good ? '🥳' : passF.hasFocus ? '🙈' : emailF.hasFocus ? '🧐' : '🧾';
  String get bubble => busy
      ? 'Checking the vault… 🔐'
      : passF.hasFocus
          ? "I'm not looking, promise 🙈"
          : emailF.hasFocus
              ? 'Ooh, very official email 🧐'
              : signup
                  ? 'New here? Welcome to the hall of accountability 🎉'
                  : 'Ready to stop lying to yourself? 😏';

  Future<void> submit() async {
    if (email.text.trim().isEmpty || pass.text.isEmpty) {
      setState(() { msg = "🤨 Both fields, please. I can't verify vibes."; good = false; shakes++; });
      return;
    }
    setState(() { busy = true; msg = null; good = false; });
    final auth = Supabase.instance.client.auth;
    try {
      if (signup) {
        final r = await auth.signUp(email: email.text.trim(), password: pass.text);
        if (r.session == null) { msg = 'Check your email to confirm your account, then log in. 📬'; good = true; }
      } else {
        await auth.signInWithPassword(email: email.text.trim(), password: pass.text);
      }
    } on AuthException catch (e) {
      msg = '😬 ${e.message}';
      good = false;
      shakes++;
    } catch (_) {
      msg = '📡 Something went wrong. Check your connection.';
      good = false;
      shakes++;
    }
    if (mounted) setState(() => busy = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(children: [
          const EmojiRain(emojis: ['🧾', '✅', '🔥', '🙈', '⏰', '🎯'], count: 10, opacity: .14),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  PopIn(
                    child: Center(
                      child: Floaty(
                        child: Container(
                          width: 112,
                          height: 112,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: sun, shape: BoxShape.circle, border: Border.all(color: ink, width: 3), boxShadow: const [BoxShadow(color: ink, offset: Offset(4, 4))]),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            switchInCurve: Curves.elasticOut,
                            transitionBuilder: (ch, a) => ScaleTransition(scale: a, child: ch),
                            child: Text(face, key: ValueKey(face), style: const TextStyle(fontSize: 56)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  PopIn(
                    delay: 120,
                    child: Center(
                      child: Sticker(
                        color: Colors.white,
                        radius: 16,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: AnimatedSwitcher(duration: const Duration(milliseconds: 250), child: Text(bubble, key: ValueKey(bubble), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700))),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const PopIn(delay: 200, child: Text('Receipts', textAlign: TextAlign.center, style: TextStyle(fontFamily: mono, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 1))),
                  const SizedBox(height: 4),
                  PopIn(delay: 280, child: Text('No proof, no progress. 🧾', textAlign: TextAlign.center, style: TextStyle(color: ink.withValues(alpha: .6), fontWeight: FontWeight.w600))),
                  const SizedBox(height: 28),
                  PopIn(delay: 360, child: TextField(controller: email, focusNode: emailF, keyboardType: TextInputType.emailAddress, decoration: fieldStyle('Email 📧'))),
                  const SizedBox(height: 12),
                  PopIn(delay: 440, child: TextField(controller: pass, focusNode: passF, obscureText: true, onSubmitted: (_) => submit(), decoration: fieldStyle('Password (6+ characters) 🔐'))),
                  if (msg != null) Padding(padding: const EdgeInsets.only(top: 14), child: Shake(trigger: shakes, child: SpeechBubble(msg!, good))),
                  const SizedBox(height: 20),
                  PopIn(delay: 520, child: FunButton(label: signup ? 'Create account 🚀' : 'Log in 🔑', onTap: submit, busy: busy)),
                  PopIn(
                    delay: 600,
                    child: TextButton(
                      onPressed: () => setState(() { signup = !signup; msg = null; }),
                      child: AnimatedSwitcher(duration: const Duration(milliseconds: 250), child: Text(signup ? 'Have an account? Log in 👋' : 'New here? Create an account ✨', key: ValueKey(signup), style: const TextStyle(fontWeight: FontWeight.w800, color: accent))),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ]),
      );
}