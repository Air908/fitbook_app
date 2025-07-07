// routes/auth/login.dart
import 'package:dart_frog/dart_frog.dart';
import '../../services/supabase_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      body: {'error': 'Method not allowed'},
      statusCode: 405,
    );
  }

  final body = await context.request.json() as Map<String, dynamic>;
  final email = body['email'] as String?;
  final password = body['password'] as String?;

  if (email == null || password == null) {
    return Response.json(
      body: {'error': 'Email and password are required'},
      statusCode: 400,
    );
  }

  try {
    final response = await SupabaseService.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user != null) {
      return Response.json(
        body: {
          'user': response.user!.toJson(),
          'token': response.session!.accessToken,
        },
      );
    } else {
      return Response.json(
        body: {'error': 'Invalid credentials'},
        statusCode: 401,
      );
    }
  } catch (e) {
    return Response.json(
      body: {'error': e.toString()},
      statusCode: 500,
    );
  }
}