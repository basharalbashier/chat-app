import 'package:get/get.dart';
import '../client/message.dart';
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
