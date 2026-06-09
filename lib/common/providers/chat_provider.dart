import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/chat_service.dart';
import '../models/message_model.dart';

final chatServiceProvider = Provider((ref) => ChatService());

final chatMessagesProvider = StreamProvider.family<List<MessageModel>, String>((ref, bookingId) {
  return ref.read(chatServiceProvider).streamMessages(bookingId);
});
