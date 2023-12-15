// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'modules/users.dart';
import 'pages/sign_up.dart';
import 'theme.dart';

final navigatorKey = GlobalKey<NavigatorState>();

// FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
//     BehaviorSubject<ReceivedNotification>();

// final BehaviorSubject<String?> selectNotificationSubject =
//     BehaviorSubject<String?>();
String? selectedNotificationPayload;
final Users u = Get.put(Users());

void main() async {
  u.init();
  WidgetsFlutterBinding.ensureInitialized();

  // const AndroidInitializationSettings initializationSettingsAndroid =
  //     AndroidInitializationSettings('launcher_icon');
  // final InitializationSettings initializationSettings = InitializationSettings(
  //   android: initializationSettingsAndroid,
  // );
  //   await flutterLocalNotificationsPlugin.initialize(initializationSettings,
  //     onSelectNotification: (String? payload) async {
  //   if (payload != null) {
  //     debugPrint('notification payload: $payload');
  //   }
  //   selectedNotificationPayload = payload;
  //   // selectNotificationSubject.add(payload);
  // });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeData,
      navigatorKey: navigatorKey, // Setting a global key for navigator

      initialRoute: "/",
      routes: {
        "/": (context) => const SignUp(),
        // '/dataConnectionExample': (context) => const DataConnectionExample(),
      },
    );
  }
}
