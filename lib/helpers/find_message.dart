import 'package:test_client/test_client.dart';
import '../modules/message.dart';

Message getReplay(int id) {
  Message message;
  try {
    message = MessagesModel.messages.singleWhere((element) => element.id == id);
  } catch (e) {
    return Message(id: 0, content: "unable to fine message", seen_by: []);
  }
  return message;
}
