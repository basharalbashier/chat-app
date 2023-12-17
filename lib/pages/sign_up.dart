import 'dart:io';

import 'package:chat/pages/list_users.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:test_client/test_client.dart';
import '../controllers/db_controller.dart';
import '../controllers/signup_controller.dart';
import '../main.dart';
// import 'package:google_sign_in/google_sign_in.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  var displayNameController = TextEditingController();
  var info = [];
  @override
  void initState() {
    _requestPermissions();
    _isAndroidPermissionGranted();
    _getIfReg();
    super.initState();
  }

  bool _notificationsEnabled = false;
  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? grantedNotificationPermission =
          await androidImplementation?.requestNotificationsPermission();
      setState(() {
        _notificationsEnabled = grantedNotificationPermission ?? false;
      });
    }
  }

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;

      setState(() {
        _notificationsEnabled = granted;
      });
    }
  }

  Future<void> _showNotificationWithActions() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          "urlLaunchActionId",
          'Action 1',
          icon: DrawableResourceAndroidBitmap('food'),
          contextual: true,
        ),
        AndroidNotificationAction(
          'id_2',
          'Action 2',
          titleColor: Color.fromARGB(255, 255, 0, 0),
          icon: DrawableResourceAndroidBitmap('secondary_icon'),
        ),
        AndroidNotificationAction(
          navigationActionId,
          'Action 3',
          icon: DrawableResourceAndroidBitmap('secondary_icon'),
          showsUserInterface: true,
          // By default, Android plugin will dismiss the notification when the
          // user tapped on a action (this mimics the behavior on iOS).
          cancelNotification: false,
        ),
      ],
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(
        1, 'plain title', 'plain body', notificationDetails,
        payload: 'item z');
  }

  @override
  Widget build(BuildContext context) {
    var signinController = Get.put(LoginController());
    return Scaffold(
      body: Center(
        child: info.isEmpty
            ? const CircularProgressIndicator.adaptive()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FloatingActionButton.extended(
                            onPressed: () async =>
                                await signinController.login(context),
                            label: const Text("Signup with Google"))
                      ],
                    ),
                  )
                ],
              ),
      ),
    );
  }

  // GoogleSignIn _googleSignIn = new GoogleSignIn();

  void _getIfReg() async {
    User data = await DBProvider.db.getMe();
    _showNotificationWithActions();
    data.name.isEmpty ? setState(() => info = [0]) : _nextPage(data);
  }

  _nextPage(User user) async {
    Get.offAll(() => ListUsers(user: user));
  }
}
