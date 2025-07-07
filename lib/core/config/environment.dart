// core/config/environment.dart
class Environment {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://fphhmcvualvnknqixmwd.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZwaGhtY3Z1YWx2bmtucWl4bXdkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4MDQxMDgsImV4cCI6MjA2NzM4MDEwOH0.W0YJfxmrucNAB-5VU5vhA3NQXLIvqmjAByhto7AIxWU',
  );

  static const String razorpayKey = String.fromEnvironment(
    'RAZORPAY_KEY',
    defaultValue: 'your-razorpay-key',
  );

  static const bool isProduction = bool.fromEnvironment(
    'PRODUCTION',
    defaultValue: false,
  );
}