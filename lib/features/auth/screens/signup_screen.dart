import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/routers/app_routes.dart';
import '../bloc/AuthController.dart';
import '../models/auth_status.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';
import '../widgets/auth_background.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final authController = Get.find<AuthController>();
  String _selectedRole = 'user';
  final List<String> _roles = ['admin', 'sub_admin', 'user'];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
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
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _signup() {
    if (_formKey.currentState!.validate()) {
      authController.signup(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _fullNameController.text.trim(),
        _selectedRole,
      );
    }
  }

  void _navigateToLogin() => Get.back();

  void _googleLogin() {
    // authController.googleSignup(); (If implemented)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<AuthController>(
        builder: (controller) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final state = controller.authState.value;
            if (state is AuthSuccess) {
              Get.snackbar('Success', state.message, backgroundColor: Colors.green, colorText: Colors.white);
            } else if (state is AuthFailure) {
              Get.snackbar('Error', state.message, backgroundColor: Colors.red, colorText: Colors.white);
            } else if (state is AuthAuthenticated) {
              Get.offAllNamed(AppRoutes.home);
            }
          });

          return AuthBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        _buildHeader(),
                        const SizedBox(height: 40),
                        _buildSignupForm(controller),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.7)],
            ),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.3), blurRadius: 20)],
          ),
          child: const Icon(Icons.fitness_center, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 24),
        Text(
          'Join FitBook',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Create your account and start your fitness journey',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSignupForm(AuthController controller) {
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
              controller: _fullNameController,
              label: 'Full Name',
              icon: Icons.person_outline,
              validator: (value) => value == null || value.length < 2 ? 'Please enter valid name' : null,
            ),
            const SizedBox(height: 20),
            AuthTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) => value == null || !value.contains('@') ? 'Enter valid email' : null,
            ),
            const SizedBox(height: 20),
            AuthTextField(
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock_outline,
              obscureText: true,
              validator: (value) => value == null || value.length < 6 ? 'Min 6 characters' : null,
            ),
            const SizedBox(height: 20),
            AuthTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              icon: Icons.lock_outline,
              obscureText: true,
              validator: (value) => value != _passwordController.text ? 'Passwords do not match' : null,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
              ),
              items: _roles.map((role) {
                return DropdownMenuItem<String>(
                  value: role,
                  child: Text(role.capitalizeFirst!),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedRole = value);
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: controller.authState.value is AuthLoading ? null : _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: controller.authState.value is AuthLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Create Account', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 24),
            _buildDivider(),
            const SizedBox(height: 24),
            SocialLoginButton(
              onPressed: _googleLogin,
              icon: FontAwesomeIcons.google,
              label: 'Continue with Google',
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              borderColor: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already have an account?', style: TextStyle(color: Colors.grey.shade700)),
                TextButton(onPressed: _navigateToLogin, child: const Text('Log in', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('or continue with', style: TextStyle(color: Colors.grey.shade600)),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
      ],
    );
  }
}
