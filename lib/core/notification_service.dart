import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../app/constants/app_constants.dart';

class NotificationService {
  static Future<void> init() async {
    // Remove this method call and replace it with your OneSignal App ID
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(AppConstants.onesignalAppId);

    // The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. 
    // We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    OneSignal.Notifications.requestPermission(true);
  }

  static Future<void> setExternalUserId(String userId) async {
    await OneSignal.login(userId);
  }

  static Future<void> removeExternalUserId() async {
    await OneSignal.logout();
  }
}
