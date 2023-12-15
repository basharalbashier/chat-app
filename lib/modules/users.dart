import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:http/http.dart' as http;
import 'package:test_client/test_client.dart';
import '../helpers/constant.dart';

class Users extends GetxController {
  RxList<User> users = List<User>.from([]).obs;

  updateUsers(User user) async {
    users.add(user);
  }

  Timer? _timer;
  init() async {
    users.clear();

    try {
      var result = await client.userEndPoint.getAllUsers();

      for (var user in result) {
        // if (user.id != widget.user.id) {
        users.add(user);
        // }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Initilazing error: $e");
      }
    }
  }

  // checkUsers() async {
  //   try {
  //     var remoteList = await http.get(Uri.parse("http://$host:9000/api/peers"));
  //     var onLine = jsonDecode(remoteList.body);
  //     for (User user in users) {
  //       for (var i in onLine) {
  //         var id = int.parse(i);
  //         if (user.id == id) {
  //           if (!user.status!) {
  //             showSnackbar("${user.name} is Online");
  //             // users.removeWhere((element) => element.id == user.id);
  //             user.status = true;
  //             user = user;
  //             // users.add(user);
  //           }
  //         } else {
  //           // users.removeWhere((element) => element.id == user.id);
  //           // user.status = false;
  //           users.elementAt(user.hashCode).status = false;
  //           // users.add(user);
  //         }
  //       }
  //     }

  //     if (_timer == null) {
  //       const oneSec = Duration(seconds: 10);
  //       _timer = Timer.periodic(
  //         oneSec,
  //         (Timer timer) async {
  //           await checkUsers();
  //         },
  //       );
  //     }
  //   } catch (e) {}
  // }

  User getUser(int id) {
    User user;
    try {
      user = users.singleWhere((element) => element.id == id);
    } catch (e) {
      return User(id: 0, name: "unable to fine message");
    }
    return user;
  }
}
