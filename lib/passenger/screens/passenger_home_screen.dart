import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/location_service.dart';
import '../providers/location_provider.dart';
import '../widgets/fare_estimate_widget.dart';
import '../providers/booking_provider.dart';
import '../../auth/providers/auth_provider.dart';

final locationServiceProvider = Provider((ref) => LocationService());

class PassengerHomeScreen extends ConsumerStatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  ConsumerState<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends ConsumerState<PassengerHomeScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await ref.read(locationServiceProvider).getCurrentLocation();
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

  void _onSearchTap(bool isPickup) async {
    final result = await context.push<Map<String, dynamic>>('/location-search?isPickup=$isPickup');
    if (result != null) {
      final location = LatLng(result['lat'], result['lng']);
      final address = result['address'];
      
      if (isPickup) {
        ref.read(passengerLocationProvider.notifier).setPickup(location, address);
      } else {
        ref.read(passengerLocationProvider.notifier).setDropoff(location, address);
      }

      if (_mapController != null) {
        _mapController!.animateCamera(CameraUpdate.newLatLngZoom(location, 15));
      }
    }
  }

  void _showSosDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('EMERGENCY SOS', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: const Text('This will send your current location to emergency services and your contacts. Proceed?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              // TODO: Logic to send SOS alert to Supabase or external API
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SOS Alert Sent!'), backgroundColor: Colors.red));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('SEND SOS'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(passengerLocationProvider);
    final activeBooking = ref.watch(activeBookingProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text('Cabs App', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('My Wallet'),
              onTap: () {
                Navigator.pop(context);
                context.push('/wallet');
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Ride History'),
              onTap: () {
                // TODO: History
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await authNotifier.signOut();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSosDialog,
        backgroundColor: Colors.red,
        child: const Icon(Icons.warning, color: Colors.white),
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
              markers: {
                if (locationState.pickupLocation != null)
                  Marker(
                    markerId: const MarkerId('pickup'),
                    position: locationState.pickupLocation!,
                    infoWindow: const InfoWindow(title: 'Pickup'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                  ),
                if (locationState.dropoffLocation != null)
                  Marker(
                    markerId: const MarkerId('dropoff'),
                    position: locationState.dropoffLocation!,
                    infoWindow: const InfoWindow(title: 'Dropoff'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                  ),
              },
            )
          else
            const Center(child: CircularProgressIndicator()),
          
          // Search Card
          Positioned(
            top: 100, // Adjusted for AppBar
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _onSearchTap(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, color: Colors.green, size: 12),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              locationState.pickupAddress ?? 'Pick up from?',
                              style: TextStyle(
                                color: locationState.pickupAddress != null ? Colors.black : Colors.grey,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _onSearchTap(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.square, color: Colors.red, size: 12),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              locationState.dropoffAddress ?? 'Where to?',
                              style: TextStyle(
                                color: locationState.dropoffAddress != null ? Colors.black : Colors.grey,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (locationState.pickupLocation != null && locationState.dropoffLocation != null && activeBooking == null)
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FareEstimateWidget(),
            ),

          if (activeBooking != null)
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Booking Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(activeBooking.status.toUpperCase(), style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (activeBooking.status == 'pending')
                      const CircularProgressIndicator()
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Icon(Icons.person),
                              const Text('Driver Found'),
                            ],
                          ),
                          IconButton(
                            onPressed: () => context.push('/chat?bookingId=${activeBooking.id}'),
                            icon: const Icon(Icons.chat, color: Colors.deepPurple, size: 32),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    if (activeBooking.status == 'pending')
                      const Text('Looking for nearby drivers...', style: TextStyle(fontSize: 18))
                    else
                      Text('Verification Code: ${activeBooking.pickupVerificationCode}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(activeBookingProvider.notifier).state = null;
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                      child: const Text('Cancel Request'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
