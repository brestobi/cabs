import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/models/booking_model.dart';
import '../../common/services/booking_service.dart';
import '../../auth/providers/auth_provider.dart';

final bookingServiceProvider = Provider((ref) => BookingService());

final activeBookingProvider = StateProvider<BookingModel?>((ref) => null);

final bookingListProvider = StreamProvider<List<BookingModel>>((ref) {
  final authState = ref.watch(authProvider);
  final bookingService = ref.read(bookingServiceProvider);
  
  if (authState.user != null) {
    return bookingService.streamUserBookings(authState.user!.id);
  }
  return Stream.value([]);
});
