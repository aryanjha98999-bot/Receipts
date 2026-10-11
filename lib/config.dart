class Config {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const geminiModel = String.fromEnvironment('GEMINI_MODEL', defaultValue: 'gemini-2.5-flash');

  static bool get hasGemini => geminiApiKey.isNotEmpty && !geminiApiKey.startsWith('PASTE_') && !geminiApiKey.startsWith('YOUR_');
}