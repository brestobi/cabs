import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import '../providers/fare_provider.dart';
import '../providers/location_provider.dart';
import '../providers/booking_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../common/models/booking_model.dart';
import '../../common/models/location_model.dart';

class FareEstimateWidget extends ConsumerWidget {
  const FareEstimateWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(passengerLocationProvider);
    final selectedVehicle = ref.watch(selectedVehicleTypeProvider);
    final fareService = ref.read(fareServiceProvider);
    final bookingService = ref.read(bookingServiceProvider);
    final authState = ref.watch(authProvider);

    if (locationState.pickupLocation == null || locationState.dropoffLocation == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: fareService.getDistanceAndDuration(
        locationState.pickupLocation!,
        locationState.dropoffLocation!,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 200,
            color: Colors.white,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Container(
            height: 100,
            color: Colors.white,
            child: const Center(child: Text('Error calculating fare')),
          );
        }

        final data = snapshot.data!;
        final distance = data['distance'] as int;
        
        final vehicleTypes = ['Standard', 'Premium', 'Large'];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Distance: ${data['distanceText']}'),
                  Text('Duration: ${data['durationText']}'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: vehicleTypes.length,
                  itemBuilder: (context, index) {
                    final type = vehicleTypes[index];
                    final fare = fareService.calculateFare(distance, type);
                    final isSelected = selectedVehicle == type;

                    return GestureDetector(
                      onTap: () => ref.read(selectedVehicleTypeProvider.notifier).state = type,
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.deepPurple[50] : Colors.grey[100],
                          border: Border.all(
                            color: isSelected ? Colors.deepPurple : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.directions_car,
                              color: isSelected ? Colors.deepPurple : Colors.grey,
                            ),
                            const SizedBox(height: 4),
                            Text(type, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('\$${fare.toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (authState.user == null) return;

                  final fare = fareService.calculateFare(distance, selectedVehicle);
                  final verificationCode = (Random().nextInt(9000) + 1000).toString();
                  
                  final booking = BookingModel(
                    id: const Uuid().v4(),
                    passengerId: authState.user!.id,
                    pickupLocation: LocationModel(
                      latitude: locationState.pickupLocation!.latitude,
                      longitude: locationState.pickupLocation!.longitude,
                    ),
                    dropoffLocation: LocationModel(
                      latitude: locationState.dropoffLocation!.latitude,
                      longitude: locationState.dropoffLocation!.longitude,
                    ),
                    pickupAddress: locationState.pickupAddress!,
                    dropoffAddress: locationState.dropoffAddress!,
                    status: 'pending',
                    fareEstimate: fare,
                    paymentMethod: 'cash', // Default
                    pickupVerificationCode: verificationCode,
                    createdAt: DateTime.now(),
                  );

                  try {
                    await bookingService.createBooking(booking);
                    ref.read(activeBookingProvider.notifier).state = booking;
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to create booking: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Confirm Booking', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        );
      },
    );
  }
}
