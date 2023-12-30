import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:http/http.dart' as http;
import 'package:test_client/test_client.dart';
import '../helpers/constant.dart';

class Channels extends GetxController {
  RxList<Message> channels = List<Message>.from([]).obs;

  updateUsers(Message user) async {
    channels.add(user);
  }

  Timer? _timer;

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
}
