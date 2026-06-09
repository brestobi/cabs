import 'package:supabase_flutter/supabase_flutter.dart';
import '../../common/models/booking_model.dart';
import '../../core/supabase_client.dart';

class BookingService {
  final _supabase = SupabaseClientConfig.client;

  Future<void> createBooking(BookingModel booking) async {
    await _supabase.from('bookings').insert(booking.toJson());
  }

  Future<List<BookingModel>> getUserBookings(String userId) async {
    final response = await _supabase
        .from('bookings')
        .select()
        .eq('passenger_id', userId)
        .order('created_at', ascending: false);
    
    return (response as List).map((json) => BookingModel.fromJson(json)).toList();
  }

  Stream<List<BookingModel>> streamUserBookings(String userId) {
    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('passenger_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => BookingModel.fromJson(json)).toList());
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _supabase.from('bookings').update({'status': status}).eq('id', bookingId);
  }
}
