import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:test_client/test_client.dart';
import '../modules/message.dart';

Message getReplay(int id) {
  Message message;
  var messages = Get.put(MessagesModel());

  try {
    message = messages.messages.singleWhere((element) => element.id == id);
  } catch (e) {
    return Message(id: 0, content: "unable to fine message", seen_by: []);
  }
  return message;
}
