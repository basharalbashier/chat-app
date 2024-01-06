import 'dart:io';

import 'package:chat/controllers/db_controller.dart';
import 'package:chat/helpers/http_get.dart';
import 'package:chat/modules/peer_client.dart';
import 'package:chat/modules/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:test_client/test_client.dart';
import '../controllers/signup_controller.dart';
import '../helpers/router.dart';
import '../modules/users.dart';
import 'chat_screen.dart';

class ListUsers extends StatefulWidget {
  const ListUsers({
    super.key,
  });
  @override
  State<ListUsers> createState() => _ListUsersState();
}

class _ListUsersState extends State<ListUsers> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void initState() {
    DBProvider.db.listMessages();

    // foo("113453572915198993517");
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    try {
      controller.scannedDataStream.listen((scanData) async {
        if (scanData.code!.isNotEmpty) {
          var user = await fetchUser(scanData.code!);
          move(context, true, ChatScreen(to: user));
        }
      });
    } catch (e) {
      controller.dispose();
      showSnackbar("Error: $e");
    }
  }

  List<Message> messages = [];
  User? me = PeerClient.client.me;

  @override
  Widget build(BuildContext context) {
    var _dx = Get.put(Channels());
    _dx.channels.removeWhere((element) => me!.uid == element.uid);

    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(me != null ? 'I am ${me!.name}' : ""),
              IconButton(
                  onPressed: () => showDialog(
                      barrierColor: Colors.white,
                      context: context,
                      builder: (context) => Center(
                            child: SizedBox(
                              width: 200,
                              height: 200,
                              child: QrImageView(
                                foregroundColor: Theme.of(context).primaryColor,
                                data: PeerClient.client.me!.uid!,
                                version: QrVersions.auto,
                                size: 200,
                              ),
                            ),
                          )),
                  icon: const Icon(Icons.qr_code))
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showDialog(
              context: context,
              builder: (context) => Center(
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: QRView(
                        key: qrKey,
                        onQRViewCreated: _onQRViewCreated,
                      ),
                    ),
                  )),
          child: const Icon(Icons.qr_code_scanner),
        ),
        body: Obx(
          () => ListView.builder(
            itemCount: _dx.channels.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => move(
                  context,
                  true,
                  ChatScreen(
                    to: _dx.channels[index],
                    // peer: peer,
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: CircleAvatar(
                              child: Text(_dx.channels[index].name[0]),
                            ),
                          ),

                          Text(_dx.channels[index].uid == me!.uid
                              ? "Me"
                              : _dx.channels[index].name),
                          // CircleAvatar(
                          //   radius: 5,
                          //   backgroundColor: _dx.users[index].status == null ||
                          //           _dx.users[index].status == false
                          //       ? Colors.pink
                          //       : Colors.teal,
                          // )
                        ],
                      ),
                    ),
                    const Divider()
                  ],
                ),
              );
            },
          ),
        ));
  }
}

Future<User> fetchUser(String id) async =>
    await httpGetRequest(id).then((value) {
      value['uid'] = value['id'].toString();
      value['id'] = null;
      var user = User.fromJson(value, Protocol());
      DBProvider.db.addUser(user, false);
      return user;
    });
