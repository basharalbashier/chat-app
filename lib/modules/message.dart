import 'package:test_client/test_client.dart';

class MessagesModel {
  static final List<Message> messages = [];

  static updateMessages(Message message) async {
    messages.add(message);
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
