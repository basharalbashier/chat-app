import 'package:flutter/material.dart';

import '../main.dart';

showSnackbar(String text) {
  ScaffoldMessenger.of(
    navigatorKey.currentContext!,
  ).showSnackBar(SnackBar(content: Text(text)));
}
