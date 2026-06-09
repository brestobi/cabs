import 'package:dio/dio.dart';
import '../app/constants/app_constants.dart';

class PushNotificationService {
  final Dio _dio = Dio();

  Future<void> sendNotification({
    required List<String> recipientIds,
    required String title,
    required String content,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _dio.post(
        'https://onesignal.com/api/v1/notifications',
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Authorization': 'Basic ${AppConstants.onesignalRestApiKey}',
          },
        ),
        data: {
          'app_id': AppConstants.onesignalAppId,
          'include_external_user_ids': recipientIds,
          'headings': {'en': title},
          'contents': {'en': content},
          'data': data,
        },
      );
    } catch (e) {
      // Handle error
    }
  }
}
