import 'package:get/get.dart';
import 'package:test_client/test_client.dart';

class Channels extends GetxController {
  RxList<User> channels = List<User>.from([]).obs;

  updateUsers(User user) async {
    channels.add(user);
  }
}
