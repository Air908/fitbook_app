// middleware/auth_middleware.dart
import 'package:dart_frog/dart_frog.dart';
import '../services/supabase_service.dart';

Middleware authMiddleware() {
  return (handler) {
    return (context) async {
      final request = context.request;
      final authHeader = request.headers['authorization'];

      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.json(
          body: {'error': 'Missing or invalid authorization header'},
          statusCode: 401,
        );
      }

      final token = authHeader.substring(7);

      try {
        final user = await SupabaseService.client.auth.getUser(token);
        return handler(context.provide(() => user.user));
      } catch (e) {
        return Response.json(
          body: {'error': 'Invalid token'},
          statusCode: 401,
        );
      }
    };
  };
}