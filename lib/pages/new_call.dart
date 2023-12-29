import 'package:chat/pages/awn_call.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peerdart/peerdart.dart';
import 'package:test_client/test_client.dart';

import '../main.dart';
import '../modules/peer_client.dart';

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
                              Get.to(AwnCall(
                                user: PeerClient.client.me!,
                                to: user,
                                isVideo: false,
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
