import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peerdart/peerdart.dart';
import 'package:test_client/test_client.dart';
import '../helpers/constant.dart';
import '../main.dart';
import '../pages/awn_call.dart';

class PeerClient {
  // const PeerClient({required this.user});
  PeerClient._();
  static final PeerClient peerClient = PeerClient._();
  Peer? peer;
  bool inCall = false;
  User? me;
  Future<void> init(User user) async {
    me = user;
    peer = Peer(
        id: user.uid.toString(),
        options: PeerOptions(
            secure: false,
            host: host,
            port: 9000,
            path: "/",
            debug: LogLevel.All));
    peer!.on<MediaConnection>("call").listen((call) async {
      var user = u.getUser(int.tryParse(call.peer) ?? 0);
      showMyDialog(user, call);
    });
  }
}

void showMyDialog(User user, MediaConnection call) {
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
                                user: PeerClient.peerClient.me!,
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
