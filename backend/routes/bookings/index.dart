// routes/bookings/index.dart
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog/dart_frog.dart' as http;
import 'package:supabase/supabase.dart';
import '../../services/supabase_service.dart';

Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case http.HttpMethod.get:
      return _getBookings(context);
    case http.HttpMethod.post:
      return _createBooking(context);
    default:
      return Response.json(
        body: {'error': 'Method not allowed'},
        statusCode: 405,
      );
  }
}

Future<Response> _createBooking(RequestContext context) async {
  final user = context.read<User>();
  final body = await context.request.json() as Map<String, dynamic>;

  // Check availability
  final existingBookings = await SupabaseService.client
      .from('bookings')
      .select()
      .eq('facility_id', body['facility_id'])
      .eq('booking_date', body['booking_date'])
      .eq('status', 'confirmed')
      .overlaps('time_range', [body['start_time'], body['end_time']]);

  if (existingBookings.isNotEmpty) {
    return Response.json(
      body: {'error': 'Time slot not available'},
      statusCode: 409,
    );
  }

  try {
    final booking = await SupabaseService.client
        .from('bookings')
        .insert({
      ...body,
      'user_id': user.id,
    })
        .select()
        .single();

    return Response.json(
      body: {'booking': booking},
      statusCode: 201,
    );
  } catch (e) {
    return Response.json(
      body: {'error': e.toString()},
      statusCode: 500,
    );
  }
}

Future<Response> _getBookings(RequestContext context) async {
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
