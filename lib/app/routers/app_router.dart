import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/screens/otp_screen.dart';
import '../../auth/screens/role_selection_screen.dart';
import '../../passenger/screens/passenger_home_screen.dart';
import '../../passenger/screens/location_search_screen.dart';
import '../../driver/screens/driver_home_screen.dart';
import '../../driver/screens/active_trip_screen.dart';
import '../../common/widgets/chat_screen.dart';
import '../../common/providers/user_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final user = ref.watch(userProvider);

  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        redirect: (context, state) {
          if (authState.status == AuthStatus.unauthenticated) {
            return '/login';
          }
          
          if (authState.status == AuthStatus.authenticated) {
            if (user == null) {
              // Waiting for user profile to load
              return null;
            }
            
            if (user.role == null) {
              return '/role-selection';
            }
            
            if (user.role == 'passenger') {
              return '/passenger-home';
            }
            
            if (user.role == 'driver') {
              return '/driver-home';
            }
          }
          return null;
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return OtpScreen(phone: phone);
        },
      ),
      GoRoute(
        path: '/role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/passenger-home',
        builder: (context, state) => const PassengerHomeScreen(),
      ),
      GoRoute(
        path: '/location-search',
        builder: (context, state) {
          final isPickup = state.uri.queryParameters['isPickup'] == 'true';
          return LocationSearchScreen(isPickup: isPickup);
        },
      ),
      GoRoute(
        path: '/driver-home',
        builder: (context, state) => const DriverHomeScreen(),
      ),
      GoRoute(
        path: '/active-trip',
        builder: (context, state) => const ActiveTripScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) {
          final bookingId = state.uri.queryParameters['bookingId'] ?? '';
          return ChatScreen(bookingId: bookingId);
        },
      ),
    ],
  );
});
