import 'package:chat/controllers/db_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  @override
  void initState() {
    setMe();
    super.initState();
  }

  User? me;
  setMe() async =>
      await DBProvider.db.getMe().then((value) => setState(() => me = value));
  @override
  Widget build(BuildContext context) {
    Users _dx = Get.put(Users());
    _dx.users.removeWhere((element) => me!.uid == element.uid);

    return Scaffold(
        appBar: AppBar(
          title: Text(me != null ? 'I am ${me!.name}' : ""),
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
