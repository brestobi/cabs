import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/models/booking_model.dart';

final driverActiveBookingProvider = StateProvider<BookingModel?>((ref) => null);
