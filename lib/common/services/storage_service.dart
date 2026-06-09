import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_client.dart';

class StorageService {
  final _supabase = SupabaseClientConfig.client;

  Future<String?> uploadFile({
    required String bucket,
    required String path,
    required File file,
  }) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final fullPath = '$path/$fileName';

      await _supabase.storage.from(bucket).upload(fullPath, file);

      final String publicUrl = _supabase.storage.from(bucket).getPublicUrl(fullPath);
      return publicUrl;
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    await _supabase.storage.from(bucket).remove([path]);
  }
}
