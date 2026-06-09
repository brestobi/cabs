import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_client.dart';
import '../../common/models/location_model.dart';
import '../../common/services/push_notification_service.dart';

class DriverService {
  final _supabase = SupabaseClientConfig.client;
  final _pushNotificationService = PushNotificationService();

  Future<void> updateDriverStatus(String driverId, bool isOnline) async {
    await _supabase.from('profiles').update({'is_online': isOnline}).eq('id', driverId);
  }

  Future<void> updateDriverLocation(String driverId, LocationModel location) async {
    await _supabase.from('profiles').update({
      'current_location': location.toJson(),
    }).eq('id', driverId);
  }

  Stream<List<Map<String, dynamic>>> streamRideRequests() {
    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('status', 'pending')
        .map((data) => data);
  }

  Future<void> acceptBooking(String bookingId, String driverId) async {
    // Fetch passenger ID first
    final bookingData = await _supabase
        .from('bookings')
        .select('passenger_id')
        .eq('id', bookingId)
        .single();
    
    final passengerId = bookingData['passenger_id'] as String;

    await _supabase.from('bookings').update({
      'driver_id': driverId,
      'status': 'accepted',
    }).eq('id', bookingId);

    // Send notification to passenger
    await _pushNotificationService.sendNotification(
      recipientIds: [passengerId],
      title: 'Ride Accepted!',
      content: 'Your driver is on the way.',
      data: {'booking_id': bookingId},
    );
  }

  Future<void> rejectBooking(String bookingId) async {
    // In a real app, we might just hide it for this driver
    // For now, we'll leave it as pending for other drivers
  }
}
