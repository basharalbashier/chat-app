import 'dart:convert';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:http/http.dart'as http;
import 'package:test_client/test_client.dart';
import '../helpers/constant.dart';

class Users extends GetxController {
    RxList users = [].obs;

  
   updateUsers(User user) async {
    users.add(user);
  }
void init()async{
    try {
      var result = await client.userEndPoint.getAllUsers();
      var onLine= await http.get(Uri.parse(host+"/api/peers"));
      onLine =jsonDecode(onLine.body);
      for (var user in result) {
        print(user);
        // if (user.id != widget.user.id) {
          users.add(user);
        // }
      }
    } catch (e) {}
  }

  Future<User> getUser(int id) async {
    User user;
    try {
      user = users.singleWhere((element) => element.id == id);
    } catch (e) {
      return User(id: 0, name: "unable to fine message");
    }
    return user;
  }
}
