import 'package:flutter/material.dart';

move(BuildContext context, bool isRoute, Widget whereToGo) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => whereToGo),
    //if you want to disable back feature set to false
  );
}
