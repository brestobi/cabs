import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationState {
  final LatLng? pickupLocation;
  final String? pickupAddress;
  final LatLng? dropoffLocation;
  final String? dropoffAddress;

  LocationState({
    this.pickupLocation,
    this.pickupAddress,
    this.dropoffLocation,
    this.dropoffAddress,
  });

  LocationState copyWith({
    LatLng? pickupLocation,
    String? pickupAddress,
    LatLng? dropoffLocation,
    String? dropoffAddress,
  }) {
    return LocationState(
      pickupLocation: pickupLocation ?? this.pickupLocation,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(LocationState());

  void setPickup(LatLng location, String address) {
    state = state.copyWith(pickupLocation: location, pickupAddress: address);
  }

  void setDropoff(LatLng location, String address) {
    state = state.copyWith(dropoffLocation: location, dropoffAddress: address);
  }

  void clear() {
    state = LocationState();
  }
}

final passengerLocationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
});
