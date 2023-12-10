import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peerdart/peerdart.dart';
import 'package:test_client/test_client.dart';
import '../helpers/constant.dart';
import '../main.dart';

class PeerClient {
  // const PeerClient({required this.user});
  PeerClient._();
  static final PeerClient peerClient = PeerClient._();
  Peer? peer;
  Future<void> init(User user) async {
    peer = Peer(
        id: user.id.toString(),
        options: PeerOptions(
            secure: false,
            host: host,
            port: 9000,
            path: "/",
            debug: LogLevel.All));
    peer!.on<MediaConnection>("call").listen((event) async {
      await u
          .getUser(int.parse(event.peer))
          .then((value) => showMyDialog(value.name));

      //  move(
      //                   context,
      //                   true,
      //                   CallScreen(
      //                     user: widget.user,
      //                     to: widget.to,
      //                     isVideo: true,
      //                     // peer:widget.peer
      //                   ));
      //         ScaffoldMessenger.of(context)
      //       .showSnackBar(SnackBar(content: Text(event.peer.toString())));
    });
  }
}

void showMyDialog(String text) {
  showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => Center(
            child: Material(
              // color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('$text is calling ..'),
              ),
            ),
          ));
}
