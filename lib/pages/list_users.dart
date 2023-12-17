import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:test_client/test_client.dart';
import '../helpers/constant.dart';
import '../helpers/router.dart';
import '../modules/peer_client.dart';
import '../modules/users.dart';
import 'chat_screen.dart';

class ListUsers extends StatefulWidget {
  const ListUsers({
    super.key,
    required this.user,
  });
  final User user;
  @override
  State<ListUsers> createState() => _ListUsersState();
}

class _ListUsersState extends State<ListUsers> {
  @override
  void initState() {
    PeerClient.peerClient.init(widget.user);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Users _dx = Get.put(Users());
    _dx.users.removeWhere((element) => widget.user.uid == element.uid);
    return Scaffold(
        appBar: AppBar(
          title: Text('I am ${widget.user.name}'),
        ),
        body: Obx(
          () => ListView.builder(
            itemCount: _dx.users.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => move(
                  context,
                  true,
                  ChatScreen(
                    user: widget.user,
                    to: _dx.users[index],
                    // peer: peer,
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: CircleAvatar(
                                // child:
                                //     Image.network(_dx.users[index].photourl ?? ""),
                                ),
                          ),

                          Text(_dx.users[index].name),
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
