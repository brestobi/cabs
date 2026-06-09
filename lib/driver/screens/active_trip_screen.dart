import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import '../providers/active_booking_provider.dart';
import '../providers/driver_provider.dart';
import '../../common/services/booking_service.dart';

class ActiveTripScreen extends ConsumerStatefulWidget {
  const ActiveTripScreen({super.key});

  @override
  ConsumerState<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends ConsumerState<ActiveTripScreen> {
  GoogleMapController? _mapController;
  final _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(driverActiveBookingProvider);
    final bookingService = ref.read(bookingServiceProvider);

    if (booking == null) {
      return const Scaffold(body: Center(child: Text('No active trip')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Trip - ${booking.status.toUpperCase()}'),
        actions: [
          IconButton(
            onPressed: () => context.push('/chat?bookingId=${booking.id}'),
            icon: const Icon(Icons.chat),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(booking.pickupLocation.latitude, booking.pickupLocation.longitude),
              zoom: 15,
            ),
            onMapCreated: (controller) => _mapController = controller,
            markers: {
              Marker(
                markerId: const MarkerId('pickup'),
                position: LatLng(booking.pickupLocation.latitude, booking.pickupLocation.longitude),
                infoWindow: const InfoWindow(title: 'Pickup'),
              ),
              Marker(
                markerId: const MarkerId('dropoff'),
                position: LatLng(booking.dropoffLocation.latitude, booking.dropoffLocation.longitude),
                infoWindow: const InfoWindow(title: 'Dropoff'),
              ),
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (booking.status == 'accepted') ...[
                    const Text('Navigate to Pickup', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(booking.pickupAddress),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await bookingService.updateBookingStatus(booking.id, 'arrived');
                        ref.read(driverActiveBookingProvider.notifier).state = booking.copyWith(status: 'arrived');
                      },
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                      child: const Text('ARRIVED AT PICKUP'),
                    ),
                  ],
                  if (booking.status == 'arrived') ...[
                    const Text('Verify Passenger', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _otpController,
                      decoration: const InputDecoration(labelText: 'Verification Code'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (_otpController.text == booking.pickupVerificationCode) {
                          await bookingService.updateBookingStatus(booking.id, 'started');
                          ref.read(driverActiveBookingProvider.notifier).state = booking.copyWith(status: 'started');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid code')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.green, foregroundColor: Colors.white),
                      child: const Text('START TRIP'),
                    ),
                  ],
                  if (booking.status == 'started') ...[
                    const Text('In Transit to Dropoff', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(booking.dropoffAddress),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await bookingService.updateBookingStatus(booking.id, 'completed');
                        ref.read(driverActiveBookingProvider.notifier).state = null;
                        if (context.mounted) {
                          context.pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.blue, foregroundColor: Colors.white),
                      child: const Text('COMPLETE TRIP'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
