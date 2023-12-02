



// Future<void> showNotificationForStore(i,  la,int d) async {
// Future.delayed(Duration(minutes: 1*d)).then((value)async {
//     if (Platform.isIOS) {
//        IOSNotificationDetails iOSPlatformChannelSpecifics =
//         IOSNotificationDetails(subtitle:la ? i['description'] : i['description']);

//     NotificationDetails platformChannelSpecifics =
//         NotificationDetails(iOS: iOSPlatformChannelSpecifics);
//     await flutterLocalNotificationsPlugin.show(
//    int.parse(    i['id']), la ? i['name'] : i['name'], la ?  i['short'] :  i['short'], platformChannelSpecifics,
//         payload: 'item x');

//   } else {
//        final ByteArrayAndroidBitmap largeIcon = ByteArrayAndroidBitmap(
//         await _getByteArrayFromUrl( '$url/d/workers/photos/${i['id']}a'));
//     final ByteArrayAndroidBitmap bigPicture = ByteArrayAndroidBitmap(
//         await _getByteArrayFromUrl('$url/d/workers/photos/${i['id']}a'));

//     final BigPictureStyleInformation bigPictureStyleInformation =
//         BigPictureStyleInformation(bigPicture,
//             largeIcon: largeIcon,
//             contentTitle: ' <b>${i['name']}</b> ',
//             htmlFormatContentTitle: true,
//             summaryText: ' <i>${i['description']}</i>',
//             htmlFormatSummaryText: true);

    
  
  
//      AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
          
//             'your channel id', 'Appsher',
//             importance: Importance.max,
//             priority: Priority.high,
//             ticker: 'ticker',
//             // subText:la? ma : me,
//              styleInformation: bigPictureStyleInformation
//             );
//             final NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);
//     //  NotificationDetails platformChannelSpecificsA =
//     //     NotificationDetails(android: androidPlatformChannelSpecifics);
//     await flutterLocalNotificationsPlugin.show(
//         int.parse(i['id'] ), la ? i['name'] : i['name'], la ? i['short'] : i['short'] , platformChannelSpecifics,
//         payload: 'item x');
//   }
// });
// }


// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
//     BehaviorSubject<ReceivedNotification>();

// final BehaviorSubject<String?> selectNotificationSubject =
//     BehaviorSubject<String?>();
// String? selectedNotificationPayload;
