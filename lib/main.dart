import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:test_client/test_client.dart';
import 'package:flutter/material.dart';
import 'package:test_flutter/pages/list_users.dart';

import 'modules/notification.dart';
import 'pages/chat_screen.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();


final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String?> selectNotificationSubject =
    BehaviorSubject<String?>();
int id = kIsWeb ? 2 : 1;
String name = DateTime.now().second.toString();
String url = 'http://192.168.137.76:8080/';
var client = Client(url);
String? selectedNotificationPayload;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('launcher_icon');
  final InitializationSettings initializationSettings =  InitializationSettings(
    android: initializationSettingsAndroid,
  );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
    selectedNotificationPayload = payload;
    selectNotificationSubject.add(payload);
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Serverpod Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => ListUsers(
              user: User(id: id, name: name),
            ),
        // '/dataConnectionExample': (context) => const DataConnectionExample(),
      },
    );
  }
}
