import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationService {
  void show(String message) {
    // Mock: print notification
    print('Notification: $message');
  }
}

final notificationServiceProvider = Provider((ref) => NotificationService());
