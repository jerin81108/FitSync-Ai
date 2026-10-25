import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

/// Supabase Service wrapper for Auth, Database queries, and Realtime syncing
class SupabaseService {
  static SupabaseClient? _client;

  static Future<void> initialize() async {
    if (!AppConfig.isSupabaseConfigured) {
      return;
    }
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        publishableKey: AppConfig.supabaseAnonKey,
      );
      _client = Supabase.instance.client;
    } catch (_) {
      // Graceful offline fallback
    }
  }

  static SupabaseClient? get client => _client;
  static bool get isInitialized => _client != null;

  // Current Auth User ID
  static String? get currentUserId => _client?.auth.currentUser?.id;

  // Sign In Anonymously (Guest Mode)
  static Future<AuthResponse?> signInAnonymously() async {
    if (!isInitialized) return null;
    try {
      return await _client!.auth.signInAnonymously();
    } catch (e) {
      return null;
    }
  }

  // Sign In with Email & Password
  static Future<AuthResponse?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) return null;
    return await _client!.auth.signInWithPassword(email: email, password: password);
  }

  // Sign Up with Email & Password
  static Future<AuthResponse?> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    if (!isInitialized) return null;
    return await _client!.auth.signUp(
      email: email,
      password: password,
      data: name != null ? {'name': name} : null,
    );
  }

  // Sign Out
  static Future<void> signOut() async {
    if (!isInitialized) return;
    await _client!.auth.signOut();
  }
}
