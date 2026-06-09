import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_client.dart';
import '../../core/notification_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  factory AuthState.initial() => AuthState(status: AuthStatus.initial);

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial()) {
    _init();
  }

  final _supabase = SupabaseClientConfig.client;

  void _init() {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      state = state.copyWith(status: AuthStatus.authenticated, user: session.user);
      NotificationService.setExternalUserId(session.user.id);
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }

    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.tokenRefreshed) {
        state = state.copyWith(status: AuthStatus.authenticated, user: session?.user);
        if (session != null) {
          NotificationService.setExternalUserId(session.user.id);
        }
      } else if (event == AuthChangeEvent.signedOut) {
        state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
        NotificationService.removeExternalUserId();
      }
    });
  }

  Future<void> signInWithPhone(String phone) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _supabase.auth.signInWithOtp(phone: phone);
      // Success, wait for OTP
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: e.toString());
    }
  }

  Future<void> verifyOtp(String phone, String token) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _supabase.auth.verifyOTP(
        type: OtpType.sms,
        token: token,
        phone: phone,
      );
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: e.toString());
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
