import 'package:chat/pages/call_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../client/user.dart';
import '../main.dart';

void showCallDialog(User user, call) {
  showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => Center(
            child: Material(
              // color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text('${user.name} is calling ..'),
                    Row(
                      children: [
                        IconButton(
                            onPressed: (() {
                              // call.

                              call.dispose();
                              Navigator.of(context).pop();
                            }),
                            icon: Icon(Icons.call_end)),
                        IconButton(
                            onPressed: (() {
                              Navigator.of(context).pop();
                              Get.to(CallScreen(
                             isCallRec:true ,
                                isVideo: true,
                                call: call,
                              ));
                            }),
                            icon: const Icon(Icons.call)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ));
}
