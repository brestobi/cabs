import 'package:dio/dio.dart';
import '../../app/constants/app_constants.dart';

class PlaceService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://maps.googleapis.com/maps/api/place';

  Future<List<Map<String, dynamic>>> getAutocomplete(String input) async {
    final String url = '$_baseUrl/autocomplete/json';
    try {
      final response = await _dio.get(url, queryParameters: {
        'input': input,
        'key': AppConstants.googleMapsApiKey,
        // Optionally add components or location for better results
      });

      if (response.statusCode == 200) {
        final predictions = response.data['predictions'] as List;
        return predictions.map((p) => {
          'description': p['description'] as String,
          'placeId': p['place_id'] as String,
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    final String url = '$_baseUrl/details/json';
    try {
      final response = await _dio.get(url, queryParameters: {
        'place_id': placeId,
        'fields': 'geometry,formatted_address',
        'key': AppConstants.googleMapsApiKey,
      });

      if (response.statusCode == 200) {
        return response.data['result'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
