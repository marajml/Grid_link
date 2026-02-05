// import 'package:firebase_messaging/firebase_messaging.dart';
//
// class Noticitaion{
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   Future<void> requestNotificationPermission() async {
//
//     NotificationSettings settings =
//     await _firebaseMessaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print('✅ Notification permission granted');
//     } else if (settings.authorizationStatus ==
//         AuthorizationStatus.provisional) {
//       print('⚠️ Provisional permission granted');
//     } else {
//       print('❌ Notification permission denied');
//     }
//   }
//   Future<String> gettoken()async{
//     String?  token=await _firebaseMessaging.getToken();
//     return token!;
//
//   }
//
// }