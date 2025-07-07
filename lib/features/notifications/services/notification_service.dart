// features/notifications/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(settings);

    // Setup FCM
    await _setupFCM();
  }

  static Future<void> _setupFCM() async {
    final messaging = FirebaseMessaging.instance;

    // Request permission
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'fitbook_notifications',
      'FitBook Notifications',
      channelDescription: 'Notifications for FitBook app',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      details,
    );
  }

  static Future<void> sendBookingConfirmation({
    required String userId,
    required String facilityName,
    required DateTime bookingDate,
    required String bookingTime,
  }) async {
    final notification = {
      'user_id': userId,
      'title': 'Booking Confirmed!',
      'message': 'Your booking at $facilityName for ${bookingDate.day}/${bookingDate.month} at $bookingTime has been confirmed.',
      'type': 'booking',
    };

    await Supabase.instance.client
        .from('notifications')
        .insert(notification);
  }

  static Future<void> sendPaymentReminder({
    required String userId,
    required String facilityName,
    required double amount,
  }) async {
    final notification = {
      'user_id': userId,
      'title': 'Payment Pending',
      'message': 'Complete your payment of ₹$amount for $facilityName to confirm your booking.',
      'type': 'payment',
    };

    await Supabase.instance.client
        .from('notifications')
        .insert(notification);
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages
}