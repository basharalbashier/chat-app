import 'dart:io';

import 'package:flutter/foundation.dart';

String host =
// kDebugMode
//     ? Platform.isAndroid
//         ? "10.0.2.2"
//         : "127.0.0.1"
//     :
"192.168.137.1";
String url = 'http://$host:8080/';
// var client = Client(url);
