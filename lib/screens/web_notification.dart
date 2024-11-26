import 'dart:html' as html;

class WebNotificationHelper {
  static Future<void> requestPermission() async {
    if (html.Notification.supported) {
      final permission = await html.Notification.requestPermission();
      if (permission == 'granted') {
        // Notification permission granted
      }
    }
  }

  static void showNotification(String title, String body) {
    if (html.Notification.supported) {
      html.Notification(title, body: body);
    }
  }
}
