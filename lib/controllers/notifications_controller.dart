// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/browser.dart';
// import 'package:timezone/data/latest.dart';

// class NotificationsController {
//   final _notificationsPlugin = FlutterLocalNotificationsPlugin();

//   Future<void> init() async {
//     initializeTimeZones();

//     setLocalLocation(
//       getLocation('Europe/Warsaw')
//     );

//     // C:\Users\kamil\Desktop\messenger\android\app\src\main\res\mipmap-mdpi
//     const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    
//     const initializationSettings = InitializationSettings(
//       android: androidSettings
//     );

//     await _notificationsPlugin.initialize(settings: initializationSettings);
//   }

//   Future<void> showNotification() async {
//     await _notificationsPlugin.show(
//       id: 1,
//       title: "LOL",
//       body: 'DA DA',
//       notificationDetails: NotificationDetails(
//         android: AndroidNotificationDetails(
//           'instant_notification_channel_id',
//           'Instant Notifications',
//           channelDescription:  'Instant',
//           importance: Importance.max,
//           priority: Priority.high
//         ),
//       )
//     );
//   }
// }