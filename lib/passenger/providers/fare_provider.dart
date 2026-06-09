import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/fare_service.dart';

final fareServiceProvider = Provider((ref) => FareService());

final selectedVehicleTypeProvider = StateProvider<String>((ref) => 'Standard');
