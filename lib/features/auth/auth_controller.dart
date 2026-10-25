import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/user_profile.dart';
import '../../core/storage/local_storage_service.dart';
import '../../core/storage/supabase_service.dart';

final localStorageProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

class AuthState {
  final UserProfile? user;
  final bool isLoading;
  final bool isGuest;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isGuest = false,
    this.errorMessage,
  });

  AuthState copyWith({
    UserProfile? user,
    bool? isLoading,
    bool? isGuest,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isGuest: isGuest ?? this.isGuest,
      errorMessage: errorMessage,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final LocalStorageService _storage;

  AuthController(this._storage) : super(const AuthState()) {
    _initUser();
  }

  void _initUser() {
    final cached = _storage.getProfile();
    if (cached != null) {
      state = state.copyWith(user: cached);
    } else {
      final guest = UserProfile.initialGuest();
      state = state.copyWith(user: guest, isGuest: true);
    }
  }

  Future<void> signInAsGuest() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final guest = UserProfile.initialGuest();
      await _storage.saveProfile(guest);
      state = state.copyWith(user: guest, isGuest: true, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> updateProfile(UserProfile updated) async {
    state = state.copyWith(isLoading: true);
    await _storage.saveProfile(updated);
    state = state.copyWith(user: updated, isLoading: false);
  }

  Future<void> completeOnboarding() async {
    if (state.user != null) {
      final updated = state.user!.copyWith(onboardingCompleted: true);
      await updateProfile(updated);
      await _storage.setOnboardingCompleted(true);
    }
  }

  Future<void> signOut() async {
    await SupabaseService.signOut();
    final guest = UserProfile.initialGuest();
    await _storage.saveProfile(guest);
    state = AuthState(user: guest, isGuest: true);
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final storage = ref.watch(localStorageProvider);
  return AuthController(storage);
});
