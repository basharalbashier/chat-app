import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_client/test_client.dart';
import 'package:test_flutter/modules/peer_client.dart';
import '../helpers/router.dart';
import '../modules/users.dart';
import 'chat_screen.dart';

class WhoYouAre extends StatefulWidget {
  const WhoYouAre({
    super.key,
  });
  @override
  State<WhoYouAre> createState() => _ListUsersState();
}

class _ListUsersState extends State<WhoYouAre> {
  @override
  void initState() {
    // getAllUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Users u = Get.put(Users());

    return Scaffold(
        appBar: AppBar(
          title: const Text('Who you are?'),
        ),
        body: Obx(
          () => ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            cacheExtent: 1000,
            itemCount: u.users.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () async {
                  var me = u.users[index];
                  await PeerClient.peerClient.init(me);
                  setState(() {
                    u.users.removeWhere((element) => me.id == element.id);
                  });
                  if (!PeerClient.peerClient.peer!.disconnected) {
                    Get.to(ListUsers(
                      user: me,
                      // peer: peer,
                    ));
                  }
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(u.users[index].name),
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

class ListUsers extends StatelessWidget {
  ListUsers({
    super.key,
    required this.user,
  });
  final User user;
  final Users u = Get.find();

  // final Peer peer;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('I am ${user.name}'),
      ),
      body: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        cacheExtent: 1000,
        itemCount: u.users.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () => move(
              context,
              true,
              ChatScreen(
                user: user,
                to: u.users[index],
                // peer: peer,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(u.users[index].name),
                      CircleAvatar(
                        radius: 5,
                        backgroundColor: u.users[index].status == null ||
                                u.users[index].status == false
                            ? Colors.pink
                            : Colors.teal,
                      )
                    ],
                  ),
                ),
                const Divider()
              ],
            ),
          );
        },
      ),
    );
  }
}
