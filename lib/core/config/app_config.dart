/// App Environment Configuration
class AppConfig {
  static const String appName = 'FitSync AI';
  static const String appVersion = '1.0.0+1';

  // Supabase Configuration (can be overridden via environment variables or dashboard)
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://xyzcompany.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'public-anon-key-placeholder',
  );

  static bool get isSupabaseConfigured =>
      supabaseUrl != 'https://xyzcompany.supabase.co' &&
      supabaseAnonKey != 'public-anon-key-placeholder';
}
