import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:test_client/test_client.dart';

import '../helpers/format_time.dart';
import 'replay_message_widget.dart';

Widget myMessage(Message message, bool isMe, size) {
  return ChatBubble(
    clipper: ChatBubbleClipper1(
        type: isMe ? BubbleType.sendBubble : BubbleType.receiverBubble),
    alignment: isMe ? Alignment.topRight : Alignment.topLeft,
    margin: const EdgeInsets.only(top: 5, bottom: 5),
    backGroundColor: isMe ? Colors.yellow[100] : Colors.grey[100],
    child: Container(
      constraints: BoxConstraints(maxWidth: size!.width * 0.7),
      child: Column(
        crossAxisAlignment:
            !isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          message.replayto != null
              ? replayWidget(isMe, message.replayto, size)
              : Visibility(
                  visible: false,
                  child: Container(),
                ),
          Text(amOrPm(message.sent_at.toString(), false),
              style: const TextStyle(color: Colors.grey, fontSize: 10)),
          Text(message.content,
              style: const TextStyle(color: Colors.black, fontSize: 16))
        ],
      ),
    ),
  );
}
