import 'package:supabase_flutter/supabase_flutter.dart';
import '../../common/models/user_model.dart';
import '../../core/supabase_client.dart';

class UserService {
  final _supabase = SupabaseClientConfig.client;

  Future<UserModel?> getUserProfile(String id) async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', id)
        .single();
    
    if (response != null) {
      return UserModel.fromJson(response);
    }
    return null;
  }

  Future<void> createUserProfile(UserModel user) async {
    await _supabase.from('profiles').upsert(user.toJson());
  }

  Future<void> updateUserRole(String id, String role) async {
    await _supabase.from('profiles').update({'role': role}).eq('id', id);
  }
}
