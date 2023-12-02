import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:test_client/test_client.dart';
import '../helpers/format_time.dart';
import '../modules/message.dart';

Widget conversationScreen(
    User user, BuildContext context, ScrollController _controller, size) {
  List todaysmessages = [];
  List otherMessages = [];
  for (var i in MessagesModel.messages) {
    if (whichDayIsIt(
            i['send_time'] != null || i['sent_time'].toString().length > 16
                ? i['send_time']
                : DateTime.now().toString()) ==
        "Today") {
      todaysmessages.add(i);
    } else {
      
      otherMessages.add(i);
    }
  }
  if (todaysmessages.isEmpty) {
    return const Center(
      child: LinearProgressIndicator(),
    );
  }
  // var message = todaysmessages[index ];

  var otherWidget = makeList(_controller, otherMessages, user, size);

  var todaytext = Visibility(visible: otherMessages.isNotEmpty,
    child: Row(children: [
      Expanded(
        flex: 1,
        child: Container(
          color: Colors.deepOrange.shade200,
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
                child: Text(
              "Today",
              style: TextStyle(fontWeight: FontWeight.w800),
            )),
          ),
        ),
      )
    ]),
  );
  var todaWidget = makeList(_controller, todaysmessages, user, size);
  var all = [ todaWidget,todaytext, otherWidget];

  return ListView.builder(
    controller: _controller,
    scrollDirection: Axis.vertical,
    shrinkWrap: true,
    reverse: true,
    cacheExtent: 1000,
    itemCount: all.length,
    itemBuilder: (BuildContext context, int index) {
      return all[index];
    },
  );
}

makeList(_controller, list, user, size) {
  return 
  ListView.builder(
    controller: _controller,
    scrollDirection: Axis.vertical,
    shrinkWrap: true,
    reverse: true,
    cacheExtent: 1000,
    itemCount: list.length,
    itemBuilder: (BuildContext context, int index) {
      var message = list[list.length - index - 1];
      return (message['sender'] == user.name)
          ? ChatBubble(
              clipper: ChatBubbleClipper1(type: BubbleType.sendBubble),
              alignment: Alignment.topRight,
              margin: const EdgeInsets.only(top: 5, bottom: 5),
              backGroundColor: Colors.yellow[100],
              child: Container(
                constraints: BoxConstraints(maxWidth: size.width * 0.7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        '${amOrPm(message['send_time'] != null || message['sent_time'].toString().length <= 16 ? message['send_time'] : DateTime.now().toString(), false)}',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 10)),
                    Text('${message['content']}',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 16))
                  ],
                ),
              ),
            )
          : ChatBubble(
              clipper: ChatBubbleClipper1(type: BubbleType.receiverBubble),
              alignment: Alignment.topLeft,
              margin: const EdgeInsets.only(top: 5, bottom: 5),
              backGroundColor: Colors.grey[100],
              child: Container(
                constraints: BoxConstraints(maxWidth: size.width * 0.7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        '${message['sender']} at ${amOrPm(message['send_time'] != null || message['sent_time'].toString().length <= 16 ? message['send_time'] : DateTime.now().toString(), false)}',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 10)),
                    Text('${message['content']}',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 16))
                  ],
                ),
              ),
            );
    },
  );

}
