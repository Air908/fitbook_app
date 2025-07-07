// routes/facilities/index.dart
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog/dart_frog.dart' as http;
import 'package:supabase/supabase.dart';
import '../../services/supabase_service.dart';

Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case http.HttpMethod.get:
      return _getFacilities(context);
    case http.HttpMethod.post:
      return _createFacility(context);
    default:
      return Response.json(
        body: {'error': 'Method not allowed'},
        statusCode: 405,
      );
  }
}

Future<Response> _getFacilities(RequestContext context) async {
  final params = context.request.uri.queryParameters;
  final city = params['city'];
  final facilityType = params['type'];
  final page = int.tryParse(params['page'] ?? '1') ?? 1;
  final limit = int.tryParse(params['limit'] ?? '10') ?? 10;

  var query = SupabaseService.client
      .from('facilities')
      .select('*, users!facilities_owner_id_fkey(full_name)')
      .eq('is_approved', true)
      .eq('is_active', true);

  if (city != null) {
    query = query.ilike('city', '%$city%');
  }

  if (facilityType != null) {
    query = query.eq('facility_type', facilityType);
  }

  try {
    final response = await query
        .range((page - 1) * limit, page * limit - 1)
        .order('created_at', ascending: false);

    return Response.json(body: {'facilities': response});
  } catch (e) {
    return Response.json(
      body: {'error': e.toString()},
      statusCode: 500,
    );
  }
}

Future<Response> _createFacility(RequestContext context) async {
  final user = context.read<User>();
  final body = await context.request.json() as Map<String, dynamic>;

  try {
    final facility = await SupabaseService.client
        .from('facilities')
        .insert({
      ...body,
      'owner_id': user.id,
    })
        .select()
        .single();

    return Response.json(
      body: {'facility': facility},
      statusCode: 201,
    );
  } catch (e) {
    return Response.json(
      body: {'error': e.toString()},
      statusCode: 500,
    );
  }
}