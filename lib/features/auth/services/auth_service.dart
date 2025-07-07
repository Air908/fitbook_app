import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<AuthResponse> signIn(String email, String password) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  Future<AuthResponse> signUp(String email, String password, {String? fullName}) async {
    try {
      return await _client.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  bool get isLoggedIn => _client.auth.currentUser != null;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Get user session
  Session? get currentSession => _client.auth.currentSession;

  // Check if user email is confirmed
  bool get isEmailConfirmed => currentUser?.emailConfirmedAt != null;

  // Refresh session
  Future<AuthResponse> refreshSession() async {
    try {
      return await _client.auth.refreshSession();
    } catch (e) {
      throw Exception('Session refresh failed: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }
}