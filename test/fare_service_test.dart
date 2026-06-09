import 'package:flutter_test/flutter_test.dart';
import 'package:cabs_app/common/services/fare_service.dart';

void main() {
  group('FareService Tests', () {
    final fareService = FareService();

    test('Standard fare calculation', () {
      final fare = fareService.calculateFare(10000, 'Standard'); // 10km
      // base 5.0 + (10 * 1.5) = 20.0
      expect(fare, 20.0);
    });

    test('Premium fare calculation', () {
      final fare = fareService.calculateFare(10000, 'Premium'); // 10km
      // base 10.0 + (10 * 2.5) = 35.0
      expect(fare, 35.0);
    });

    test('Large fare calculation', () {
      final fare = fareService.calculateFare(10000, 'Large'); // 10km
      // base 15.0 + (10 * 3.5) = 50.0
      expect(fare, 50.0);
    });
  });
}
