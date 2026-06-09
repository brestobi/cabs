import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_client.dart';
import '../models/message_model.dart';
import 'push_notification_service.dart';

class ChatService {
  final _supabase = SupabaseClientConfig.client;
  final _pushNotificationService = PushNotificationService();

  Future<void> sendMessage(MessageModel message) async {
    await _supabase.from('messages').insert(message.toJson());

    // Fetch the booking to find the recipient
    final bookingData = await _supabase
        .from('bookings')
        .select('passenger_id, driver_id')
        .eq('id', message.bookingId)
        .single();

    final passengerId = bookingData['passenger_id'] as String;
    final driverId = bookingData['driver_id'] as String?;

    // The recipient is whoever is not the sender
    final recipientId = (message.senderId == passengerId) ? driverId : passengerId;

    if (recipientId != null) {
      await _pushNotificationService.sendNotification(
        recipientIds: [recipientId],
        title: 'New Message',
        content: message.text,
        data: {'booking_id': message.bookingId, 'type': 'chat'},
      );
    }
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
