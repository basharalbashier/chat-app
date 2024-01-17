import 'package:get/get.dart';
import '../client/user.dart';

class Channels extends GetxController {
  RxList<User> channels = List<User>.from([]).obs;

  updateUsers(User user) async {
    channels.add(user);
  }
}
