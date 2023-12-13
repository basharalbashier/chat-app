import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:test_client/test_client.dart';
import 'package:test_flutter/helpers/constant.dart';
import 'package:test_flutter/modules/peer_client.dart';
import '../helpers/router.dart';
import '../modules/users.dart';
import 'chat_screen.dart';

class WhoYouAre extends StatelessWidget {
  const WhoYouAre({
    super.key,
  });

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
                  // u.checkUsers();
                  var me = u.users[index];
                  await PeerClient.peerClient.init(me);
                  u.users.removeWhere((element) => me.id == element.id);
                  if (!PeerClient.peerClient.peer!.disconnected) {
                    Get.to(() => ListUsers(
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

class ListUsers extends StatefulWidget {
  ListUsers({
    super.key,
    required this.user,
  });
  final User user;
  @override
  State<ListUsers> createState() => _ListUsersState();
}

class _ListUsersState extends State<ListUsers> {
  late final StreamingConnectionHandler connectionHandler;
  Client? innerClient;

  @override
  void initState() {
    innerClient = Client("$url?id=${widget.user.id}&&key=user/")
      ..connectivityMonitor = FlutterConnectivityMonitor();
    connectionHandler = StreamingConnectionHandler(
      client: innerClient!,
      listener: (connectionState) {
        setState(() {});
      },
    );
    connectionHandler.connect();
    _listenToUpdates();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Users _dx = Get.put(Users());

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
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_dx.users[index].name),
                          CircleAvatar(
                            radius: 5,
                            backgroundColor: _dx.users[index].status == null ||
                                    _dx.users[index].status == false
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
        ));
  }

  Future<void> _listenToUpdates() async {
    await for (var update in innerClient!.userEndPoint.stream) {
      print(update);

      if (update is User) {}
    }
  }
}
