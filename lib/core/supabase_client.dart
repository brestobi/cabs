import 'package:supabase_flutter/supabase_flutter.dart';
import '../app/constants/app_constants.dart';

class SupabaseClientConfig {
  static Future<void> init() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
