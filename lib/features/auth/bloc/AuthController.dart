import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/AppPreferences.dart';
import '../models/auth_status.dart';

class AuthController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  var isLoading = false.obs;
  var currentUser = Rxn<User>();
  var authState = Rx<AuthStatus>(AuthInitial());

  @override
  void onInit() {
    super.onInit();
    _setupAuthListener();
    checkAuthStatus();
  }

  void _setupAuthListener() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session?.user != null) {
        currentUser.value = session!.user;
        authState.value = AuthAuthenticated(session.user);
      } else {
        currentUser.value = null;
        authState.value = AuthInitial();
      }
    });
  }


  Future<void> login(String email, String password) async {
    authState.value = AuthLoading();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user != null) {
        if (user.emailConfirmedAt == null) {
          authState.value = AuthFailure('Please verify your email before logging in');
        } else {
          currentUser.value = user;

          /// ✅ Save to Shared Preferences
          await AppPreferences.setValue(AppPreferences.keyIsLoggedIn, true);
          await AppPreferences.setValue(AppPreferences.keyUserId, user.id);
          await AppPreferences.setValue(AppPreferences.keyUserEmail, user.email ?? '');
          await AppPreferences.setValue(AppPreferences.keyUserName, user.userMetadata?['full_name'] ?? '');
          await AppPreferences.setValue(AppPreferences.keyUserRole, user.userMetadata?['role'] ?? 'user');
          await AppPreferences.setValue(AppPreferences.keyAvatarUrl, user.userMetadata?['avatar_url'] ?? '');
          await AppPreferences.setValue(AppPreferences.keyAuthToken, response.session?.accessToken ?? '');
          authState.value = AuthAuthenticated(user);
        }
      } else {
        authState.value = AuthFailure('Login failed: No user returned');
      }
    } on AuthException catch (e) {
      authState.value = AuthFailure(_getReadableError(e.message));
    } catch (e) {
      authState.value = AuthFailure('Login failed: ${e.toString()}');
    }
  }

  Future<void> signup(String email, String password, String fullName, String role) async {
    authState.value = AuthLoading();
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role,
        },
      );

      final user = response.user;
      if (user != null) {
        final avatarUrl = role.toLowerCase() == 'admin'
            ? 'https://fphhmcvualvnknqixmwd.supabase.co/storage/v1/object/public/images/adminUser.png'
            : 'https://fphhmcvualvnknqixmwd.supabase.co/storage/v1/object/public/images/defaultUser.jpg';

        await _supabase.from('users').upsert({
          'id': user.id,
          'email': email,
          'full_name': fullName,
          'phone': '',
          'role': role,
          'region': '',
          'avatar_url': avatarUrl,
          'is_verified': false,
          'loyalty_points': 0,
          'created_at': DateTime.now().toIso8601String(),
        });

        if (user.emailConfirmedAt == null) {
          authState.value = AuthSuccess('Please check your email to confirm your account');
        } else {
          currentUser.value = user;
          authState.value = AuthAuthenticated(user);
        }
      } else {
        authState.value = AuthFailure('Signup failed: No user returned');
      }
    } on AuthException catch (e) {
      authState.value = AuthFailure(_getReadableError(e.message));
    } catch (e) {
      authState.value = AuthFailure('Signup failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      currentUser.value = null;
      authState.value = AuthInitial();
    } catch (e) {
      authState.value = AuthFailure('Logout failed: ${e.toString()}');
    }
  }

  Future<void> forgotPassword(String email) async {
    authState.value = AuthLoading();
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      authState.value = AuthSuccess('Password reset email sent! Check your inbox.');
    } on AuthException catch (e) {
      authState.value = AuthFailure(_getReadableError(e.message));
    } catch (e) {
      authState.value = AuthFailure('Password reset failed: ${e.toString()}');
    }
  }

  void checkAuthStatus() {
    final user = _supabase.auth.currentUser;
    currentUser.value = user;
    if (user != null) {
      authState.value = AuthAuthenticated(user);
    } else {
      authState.value = AuthInitial();
    }
  }

  String _getReadableError(String error) {
    switch (error.toLowerCase()) {
      case 'invalid login credentials':
        return 'Invalid email or password';
      case 'user not found':
        return 'No account found with this email';
      case 'invalid email':
        return 'Please enter a valid email address';
      case 'weak password':
        return 'Password should be at least 6 characters';
      case 'email already registered':
        return 'An account with this email already exists';
      default:
        return error;
    }
  }
}