import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../client/message.dart';

class MessagesModel extends GetxController {
  RxList<Message> messages = List<Message>.from([]).obs;

  updateMessages(Message message) async {
    messages.add(message);
  }

  clear() {
    messages.clear();
  }

  //   void _sendMessage() async {
  //   String messageText = _messageController.text.trim();
  //   if (messageText != '') {
  //     Message message = Message(
  //         content: messageText,
  //         sender: widget.user.uid,
  //         sent_to: widget.to.uid,
  //         seen_by: [],
  //         group: false,
  //         deleted: false,
  //         replayto: replyMessage != null ? replyMessage!.id : null);
  //     if (connectionHandler.status.status.index == 0) {
  //       await innerClient!.messageEndPoint.sendStreamMessage(message);
  //       _messageController.text = '';
  //       replyMessage = null;
  //     }
  //   }
  // }
}
