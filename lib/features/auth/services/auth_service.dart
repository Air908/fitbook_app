import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Sign in with email and password
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  /// Sign up with email, password, full name and role
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      return await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role,
        },
      );
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  /// Reset password via email
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  /// Refresh user session
  Future<AuthResponse> refreshSession() async {
    try {
      return await _client.auth.refreshSession();
    } catch (e) {
      throw Exception('Session refresh failed: ${e.toString()}');
    }
  }

  /// Returns the currently signed-in user
  User? get currentUser => _client.auth.currentUser;

  /// Returns the current user session
  Session? get currentSession => _client.auth.currentSession;

  /// Checks if the user is logged in
  bool get isLoggedIn => currentUser != null;

  /// Checks if the user's email is confirmed
  bool get isEmailConfirmed => currentUser?.emailConfirmedAt != null;

  /// Listen for auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
