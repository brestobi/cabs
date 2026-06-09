import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/place_service.dart';

final placeServiceProvider = Provider((ref) => PlaceService());
