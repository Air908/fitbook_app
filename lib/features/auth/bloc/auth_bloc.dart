// lib/features/auth/bloc/auth_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// -------------------- Events --------------------
abstract class AuthEvent {}

class AppStarted extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested(this.email, this.password);
}

class SignupRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String role; // ✅ Add this
  SignupRequested(this.email, this.password, this.fullName, this.role);
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class ForgotPasswordRequested extends AuthEvent {
  final String email;
  ForgotPasswordRequested(this.email);
}

class AuthStateChanged extends AuthEvent {
  final AuthState authState;
  AuthStateChanged(this.authState);
}

/// -------------------- States --------------------
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}

class AuthSuccess extends AuthState {
  final String message;
  AuthSuccess(this.message);
}

/// -------------------- BLoC --------------------
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseClient _supabase;
  StreamSubscription? _authSubscription;

  AuthBloc(this._supabase) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<SignupRequested>(_onSignupRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<AuthStateChanged>(_onAuthStateChanged);

    _setupAuthListener();
  }

  void _setupAuthListener() {
    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.tokenRefreshed) {
        if (session?.user != null) {
          add(AuthStateChanged(AuthAuthenticated(session!.user)));
        }
      } else if (event == AuthChangeEvent.signedOut) {
        add(AuthStateChanged(AuthUnauthenticated()));
      }
    });
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));
    add(CheckAuthStatus());
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: event.email,
        password: event.password,
      );

      if (response.user != null) {
        if (response.user!.emailConfirmedAt == null) {
          emit(AuthFailure('Please verify your email before logging in'));
        } else {
          emit(AuthAuthenticated(response.user!));
        }
      } else {
        emit(AuthFailure('Login failed: No user returned'));
      }
    } on AuthException catch (e) {
      emit(AuthFailure(_getReadableError(e.message)));
    } catch (e) {
      emit(AuthFailure('Login failed: ${e.toString()}'));
    }
  }

  Future<void> _onSignupRequested(SignupRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _supabase.auth.signUp(
        email: event.email,
        password: event.password,
        data: {'full_name': event.fullName,
          'role': event.role, // ✅ Include role here
        },
      );

      if (response.user != null) {
        if (response.user!.emailConfirmedAt == null) {
          emit(AuthSuccess('Please check your email to confirm your account'));
        } else {
          emit(AuthAuthenticated(response.user!));
        }
      } else {
        emit(AuthFailure('Signup failed: No user returned'));
      }
    } on AuthException catch (e) {
      emit(AuthFailure(_getReadableError(e.message)));
    } catch (e) {
      emit(AuthFailure('Signup failed: ${e.toString()}'));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    try {
      await _supabase.auth.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure('Logout failed: ${e.toString()}'));
    }
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onForgotPasswordRequested(ForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _supabase.auth.resetPasswordForEmail(event.email);
      emit(AuthSuccess('Password reset email sent! Check your inbox.'));
    } on AuthException catch (e) {
      emit(AuthFailure(_getReadableError(e.message)));
    } catch (e) {
      emit(AuthFailure('Password reset failed: ${e.toString()}'));
    }
  }

  Future<void> _onAuthStateChanged(AuthStateChanged event, Emitter<AuthState> emit) async {
    emit(event.authState);
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

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
