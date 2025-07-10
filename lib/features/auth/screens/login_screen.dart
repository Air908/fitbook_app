import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/routers/app_routes.dart';
import '../bloc/AuthController.dart';
import '../models/auth_status.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final authController = Get.find<AuthController>();

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      authController.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  void _navigateToSignup() => Get.toNamed(AppRoutes.signup);
  void _navigateToForgotPassword() => Get.toNamed('/forgot-password');
  void _googleLogin() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final state = authController.authState.value;

        // ✅ Navigate to home on authenticated
        if (state is AuthAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offAllNamed(AppRoutes.home, arguments: state.user);
          });
        }

        // ✅ Show error
        if (state is AuthFailure) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.snackbar('Error', state.message,
                backgroundColor: Colors.red, colorText: Colors.white);
          });
        }

        // ✅ Show success message
        if (state is AuthSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.snackbar('Success', state.message,
                backgroundColor: Colors.green, colorText: Colors.white);
          });
        }

        return AuthBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      _buildHeader(),
                      const SizedBox(height: 48),
                      _buildLoginForm(),
                      const SizedBox(height: 32),
                      _buildSignupLink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.7),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 20,
              ),
            ],
          ),
          child: const Icon(Icons.fitness_center, size: 60, color: Colors.white),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome Back!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue your fitness journey',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AuthTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) =>
              value == null || value.isEmpty ? 'Please enter your email' : null,
            ),
            const SizedBox(height: 20),
            AuthTextField(
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock_outline,
              obscureText: true,
              validator: (value) =>
              value == null || value.isEmpty ? 'Please enter your password' : null,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _navigateToForgotPassword,
                child: Text('Forgot Password?', style: TextStyle(color: Theme.of(context).primaryColor)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: authController.authState.value is AuthLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: authController.authState.value is AuthLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Sign In', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 24),
            _buildSocialDivider(),
            const SizedBox(height: 24),
            SocialLoginButton(
              onPressed: _googleLogin,
              icon: FontAwesomeIcons.google,
              label: 'Continue with Google',
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              borderColor: Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('or continue with', style: TextStyle(color: Colors.grey.shade600)),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildSignupLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Don\'t have an account?', style: TextStyle(color: Colors.white70)),
        TextButton(
          onPressed: _navigateToSignup,
          child: const Text('Sign Up', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
