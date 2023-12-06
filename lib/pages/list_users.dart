import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:test_client/test_client.dart';
import 'package:test_flutter/main.dart';

import '../controllers/router_controller.dart';
import '../helpers/router.dart';
import 'chat_screen.dart';

class ListUsers extends StatefulWidget {
  const ListUsers({super.key, required this.user});
  final User user;
  @override
  State<ListUsers> createState() => _ListUsersState();
}

class _ListUsersState extends State<ListUsers> {
  getAllUsers() async {
    try {
      var result = await client.userEndPoint.getAllUsers();
      for (var user in result) {
        if (user.id != widget.user.id) {
          setState(() => users.add(user));
        }
      }
    } catch (e) {}
  }

  List<User> users = [];
  @override
  void initState() {
    getAllUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        cacheExtent: 1000,
        itemCount: users.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () => move(context,true,  ChatScreen(user: widget.user, to: users[index]),),
         
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(users[index].name),
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
