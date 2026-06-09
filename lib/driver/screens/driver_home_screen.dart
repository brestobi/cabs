import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import '../providers/driver_provider.dart';
import '../providers/active_booking_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../core/location_service.dart';

class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await LocationService().getCurrentLocation();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      if (_mapController != null && _currentLocation != null) {
        _mapController!.animateCamera(CameraUpdate.newLatLngZoom(_currentLocation!, 15));
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(driverOnlineProvider);
    final rideRequests = ref.watch(rideRequestsProvider);
    final authState = ref.watch(authProvider);
    final activeBooking = ref.watch(driverActiveBookingProvider);

    // If there's an active booking, redirect to active trip screen
    if (activeBooking != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.push('/active-trip');
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
        actions: [
          Switch(
            value: isOnline,
            onChanged: (value) async {
              if (authState.user == null) return;
              
              ref.read(driverOnlineProvider.notifier).state = value;
              await ref.read(driverServiceProvider).updateDriverStatus(authState.user!.id, value);
              
              if (value) {
                ref.read(driverLocationTrackingProvider.notifier).startTracking();
              } else {
                ref.read(driverLocationTrackingProvider.notifier).stopTracking();
              }
            },
            activeColor: Colors.green,
          ),
          const SizedBox(width: 8),
          Center(
            child: Text(
              isOnline ? 'ONLINE' : 'OFFLINE',
              style: TextStyle(
                color: isOnline ? Colors.green : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          if (_currentLocation != null)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLocation!,
                zoom: 15,
              ),
              onMapCreated: (controller) => _mapController = controller,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            )
          else
            const Center(child: CircularProgressIndicator()),
          
          if (isOnline && activeBooking == null)
            rideRequests.when(
              data: (bookings) {
                if (bookings.isEmpty) {
                  return const Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Waiting for ride requests...', textAlign: TextAlign.center),
                      ),
                    ),
                  );
                }

                final booking = bookings.first; // Show the latest request

                return Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('New Ride Request!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          ListTile(
                            leading: const Icon(Icons.location_on, color: Colors.green),
                            title: const Text('Pickup'),
                            subtitle: Text(booking.pickupAddress),
                          ),
                          ListTile(
                            leading: const Icon(Icons.location_on, color: Colors.red),
                            title: const Text('Dropoff'),
                            subtitle: Text(booking.dropoffAddress),
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Fare: \$${booking.fareEstimate.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      // Reject
                                    },
                                    child: const Text('REJECT', style: TextStyle(color: Colors.red)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (authState.user == null) return;
                                      await ref.read(driverServiceProvider).acceptBooking(booking.id, authState.user!.id);
                                      ref.read(driverActiveBookingProvider.notifier).state = booking.copyWith(status: 'accepted', driverId: authState.user!.id);
                                      if (context.mounted) {
                                        context.push('/active-trip');
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                    child: const Text('ACCEPT'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (e, s) => const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}
