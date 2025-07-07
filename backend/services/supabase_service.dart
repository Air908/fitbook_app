// services/supabase_service.dart
import 'package:supabase/supabase.dart';

class SupabaseService {
  static SupabaseClient? _client;

  static SupabaseClient get client {
    _client ??= SupabaseClient(
      'https://fphhmcvualvnknqixmwd.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZwaGhtY3Z1YWx2bmtucWl4bXdkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4MDQxMDgsImV4cCI6MjA2NzM4MDEwOH0.W0YJfxmrucNAB-5VU5vhA3NQXLIvqmjAByhto7AIxWU',
    );
    return _client!;
  }

  static Future<void> initialize() async {
    client; // Initialize client
  }
}