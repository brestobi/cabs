import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../constants/app_constants.dart';

class FareService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://maps.googleapis.com/maps/api/distancematrix/json';

  Future<Map<String, dynamic>?> getDistanceAndDuration(LatLng origin, LatLng destination) async {
    try {
      final response = await _dio.get(_baseUrl, queryParameters: {
        'origins': '${origin.latitude},${origin.longitude}',
        'destinations': '${destination.latitude},${destination.longitude}',
        'key': AppConstants.googleMapsApiKey,
      });

      if (response.statusCode == 200) {
        final element = response.data['rows'][0]['elements'][0];
        if (element['status'] == 'OK') {
          return {
            'distance': element['distance']['value'] as int, // in meters
            'duration': element['duration']['value'] as int, // in seconds
            'distanceText': element['distance']['text'] as String,
            'durationText': element['duration']['text'] as String,
          };
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  double calculateFare(int distanceInMeters, String vehicleType) {
    double baseFare = 5.0;
    double perKmRate = 1.5;

    switch (vehicleType) {
      case 'Premium':
        baseFare = 10.0;
        perKmRate = 2.5;
        break;
      case 'Large':
        baseFare = 15.0;
        perKmRate = 3.5;
        break;
    }

    double distanceInKm = distanceInMeters / 1000.0;
    return baseFare + (distanceInKm * perKmRate);
  }
}
