// lib/features/profile/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/AppPreferences.dart';
import '../../auth/bloc/AuthController.dart';

class ProfileScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = authController.currentUser.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authController.logout();
              await AppPreferences.clear();
              Get.offAllNamed('/login');
            },
          )
        ],
      ),
      body: user == null
          ? const Center(child: Text('No user data available'))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  AppPreferences.keyAvatarUrl ??
                      'https://fphhmcvualvnknqixmwd.supabase.co/storage/v1/object/public/images/defaultUser.jpg',
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoTile('Full Name', AppPreferences.keyUserName ?? 'N/A'),
            _buildInfoTile('Email', AppPreferences.keyUserEmail ?? 'N/A'),
            _buildInfoTile('Role', AppPreferences.keyUserRole ?? 'User'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Get.toNamed('/edit-profile'),
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(value),
    );
  }
}
