import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';

class UserProfileHeader extends StatelessWidget {
  final User user;
  final VoidCallback onProfileTap;

  const UserProfileHeader({
    super.key,
    required this.user,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundImage: user.email != null
              ? NetworkImage(user.email!)
              : const AssetImage('assets/images/avatar_placeholder.png')
          as ImageProvider,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.role ?? 'User',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user.email??"",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onProfileTap,
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ],
    );
  }
}