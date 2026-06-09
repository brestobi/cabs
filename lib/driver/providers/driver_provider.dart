import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/driver_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../core/location_service.dart';
import '../../common/models/location_model.dart';
import '../../common/models/booking_model.dart';

final driverServiceProvider = Provider((ref) => DriverService());

final driverOnlineProvider = StateProvider<bool>((ref) => false);

final rideRequestsProvider = StreamProvider<List<BookingModel>>((ref) {
  final driverService = ref.read(driverServiceProvider);
  return driverService.streamRideRequests().map(
    (data) => data.map((json) => BookingModel.fromJson(json)).toList(),
  );
});

class DriverLocationNotifier extends StateNotifier<void> {
  final Ref _ref;
  Timer? _timer;

  DriverLocationNotifier(this._ref) : super(null);

  void startTracking() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final isOnline = _ref.read(driverOnlineProvider);
      if (!isOnline) {
        timer.cancel();
        return;
      }

      final authState = _ref.read(authProvider);
      if (authState.user == null) return;

      try {
        final position = await LocationService().getCurrentLocation();
        await _ref.read(driverServiceProvider).updateDriverLocation(
              authState.user!.id,
              LocationModel(latitude: position.latitude, longitude: position.longitude),
            );
      } catch (e) {
        // Handle error
      }
    });
  }

  void stopTracking() {
    _timer?.cancel();
  }
}

final driverLocationTrackingProvider = StateNotifierProvider<DriverLocationNotifier, void>((ref) {
  return DriverLocationNotifier(ref);
});
