import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_client.dart';
import '../models/message_model.dart';

class ChatService {
  final _supabase = SupabaseClientConfig.client;

  Future<void> sendMessage(MessageModel message) async {
    await _supabase.from('messages').insert(message.toJson());
  }

  Stream<List<MessageModel>> streamMessages(String bookingId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('booking_id', bookingId)
        .order('created_at', ascending: true)
        .map((data) => data.map((json) => MessageModel.fromJson(json)).toList());
  }
}
