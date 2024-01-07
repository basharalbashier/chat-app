import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../main.dart';

showSnackbar(String text) {
  try {
    ScaffoldMessenger.of(
      navigatorKey.currentContext!,
    ).showSnackBar(SnackBar(content: Text(text)));
  } catch (e) {
    if (kDebugMode) {
      print(e.toString());
    }
  }
}
