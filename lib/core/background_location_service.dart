import 'dart:isolate';
import 'dart:ui';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_client.dart';
import '../common/models/location_model.dart';
import '../app/constants/app_constants.dart';

class BackgroundLocationService {
  static const String _isolateName = "LocatorIsolate";

  static Future<void> init() async {
    await BackgroundLocator.initialize();
  }

  static Future<void> startLocationService(String userId) async {
    await BackgroundLocator.registerLocationUpdate(
      LocationCallbackHandler.callback,
      initCallback: LocationCallbackHandler.initCallback,
      initDataCallback: {'user_id': userId},
      disposeCallback: LocationCallbackHandler.disposeCallback,
      iosSettings: const IOSSettings(accuracy: LocationAccuracy.HIGH, distanceFilter: 10),
      androidSettings: const AndroidSettings(
        accuracy: LocationAccuracy.HIGH,
        interval: 5,
        distanceFilter: 10,
        clientRequired: true,
        androidNotificationSettings: AndroidNotificationSettings(
          notificationChannelName: 'Location Tracking',
          notificationTitle: 'Driver Online',
          notificationMsg: 'Tracking your location in the background',
          notificationBigMsg: 'Keep the app running to receive ride requests',
          notificationIconColor: 0xFF673AB7,
        ),
      ),
    );
  }

  static Future<void> stopLocationService() async {
    await BackgroundLocator.unRegisterLocationUpdate();
  }
}

class LocationCallbackHandler {
  static Future<void> initCallback(Map<dynamic, dynamic> params) async {
    // Initialize Supabase in the isolate if needed, but normally we just send data
  }

  static Future<void> disposeCallback() async {
    // Cleanup
  }

  static Future<void> callback(LocationDto locationDto) async {
    // This is called in a separate isolate. 
    // We need to initialize Supabase here as well because it's a new isolate.
    
    // For a production app, you might want to use a more efficient way to pass the userId
    // For now, we'll assume the userId is passed in initDataCallback and we'll use it here.
    
    // Note: In a real isolate, we can't easily access the same Supabase instance.
    // We would need to re-initialize or use a different communication method.
    // For this prototype, we'll show the structure.
  }
}
