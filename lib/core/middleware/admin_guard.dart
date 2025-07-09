import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return null; // Delay redirect until async check is done
  }

  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    final isAdmin = await isAdminUser();
    if (!isAdmin) {
      return GetNavConfig.fromRoute('/unauthorized');
    }
    return await super.redirectDelegate(route);
  }

  Future<bool> isAdminUser() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;

    final response = await Supabase.instance.client
        .from('users')
        .select('role')
        .eq('id', user.id)
        .maybeSingle();

    return response != null && response['role'] == 'admin';
  }
}
