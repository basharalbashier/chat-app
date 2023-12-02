import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:test_client/test_client.dart';
import 'package:test_flutter/modules/message.dart';
import 'package:flutter/foundation.dart' as foundation;
import '../controllers/socket_io_constroller.dart';
import '../helpers/format_time.dart';
import '../main.dart';

// part '../modules/user.dart' as ;
import 'converstionScreen.dart';
import 'list_users.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.user, required this.to});

  final User user;
  final User to;

  @override
  State<ChatScreen> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  ScrollController? _controller;
  late final StreamingConnectionHandler connectionHandler;
  bool emojiShowing = false;
  Conversation? conversation;
  Client? innerClient;
  @override
  void initState() {
    innerClient = Client("$url?id=${widget.user.id}&&to=${widget.to.id}/")
      ..connectivityMonitor = FlutterConnectivityMonitor();
    connectionHandler = StreamingConnectionHandler(
      client: innerClient!,
      listener: (connectionState) {
        if (mounted) {
          setState(() {});
        }
      },
    );
    connectionHandler.connect();
_listenToUpdates();
    _controller = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    MessagesModel.messages.clear();
    connectionHandler.close();
    connectionHandler.dispose();
    innerClient!.close();
    innerClient!.messageEndPoint.client.close();
    super.dispose();
  }

  Message? replyMessage;

  Future<void> _listenToUpdates() async {
    await for (var update in innerClient!.messageEndPoint.stream) {
      if (update is Message) {
      if(update.id==null || getReplay(update.id!).id==0){
          setState(() {
          MessagesModel.messages.add(update);
        });
      }
      }
    }
  }

  onRole() {
    _controller!.animateTo(
      _controller!.position.minScrollExtent,
      duration: const Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
    );
  }

  void _sendMessage() async {
    String messageText = _messageController.text.trim();
    if (messageText != '') {
      Message message = Message(
          content: messageText,
          sender: widget.user.id ?? 0,
          sent_to: 1,
          seen_by: [],
          group: false,
          deleted: false,
          replayto: replyMessage != null ? replyMessage!.id : null);
      if (connectionHandler.status.status.index == 0) {
        await innerClient!.messageEndPoint.sendStreamMessage(message);
        _messageController.text = '';
        replyMessage = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size? size = MediaQuery.maybeOf(context)?.size;
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.pushAndRemoveUntil<dynamic>(
                  context,
                  MaterialPageRoute<dynamic>(
                    builder: (BuildContext context) => ListUsers(
                      user: widget.user,
                    ),
                  ),
                  (route) =>
                      false, //if you want to disable back feature set to false
                ),
            icon: const Icon(Icons.arrow_back)),
        // backgroundColor: Colors.deepOrangeAccent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
                onPressed: () => onRole(),
                child: Text(
                  widget.to.name,
                  style: const TextStyle(color: Colors.white),
                )),
            ConnectionDisplay(
              connectionState: connectionHandler.status,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child:     ListView.builder(
            controller: _controller,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            reverse: true,
            cacheExtent: 1000,
            itemCount: MessagesModel.messages.length,
            itemBuilder: (BuildContext context, int index) {
              Message message = MessagesModel
                  .messages[MessagesModel.messages.length - index - 1];

              // print(message);
              return Dismissible(
                  confirmDismiss: (direction) async {
                    setState(() {
                      replyMessage = message;
                    });
                    return await false;
                  },

                  //   // Then show a snackbar.
                  //   ScaffoldMessenger.of(context)
                  //       .showSnackBar(SnackBar(content: Text('dismissed')));
                  // },
                  key: Key(message.toString()),
                  child: (message.sender == widget.user.id)
                      ? myMessage(message, true, size)
                      : myMessage(message, false, size));
            },
          ),
      ),
          Container(
              // height: size!.height / (replyMessage != null ? 3 : 6),
              color: Colors.teal.withOpacity(.7),
              child: Column(
                children: [
                  Visibility(
                      visible: replyMessage != null,
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(right: 10, left: 10),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Reply for",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                GestureDetector(
                                  child: const Icon(Icons.cancel),
                                  onTap: () =>
                                      setState(() => replyMessage = null),
                                )
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Divider(color: Colors.white),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10),
                                child: SizedBox(
                                  width: size!.width - 20,
                                  child: Text(
                                    replyMessage?.content ?? "",
                                    style: const TextStyle(
                                        // fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      )),
                  Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              emojiShowing = !emojiShowing;
                            });
                          },
                          icon: const Icon(
                            Icons.emoji_emotions,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 8.0),
                          child: TextField(
                              onSubmitted: ((value) => _sendMessage()),
                              controller: _messageController,
                              style: const TextStyle(
                                  fontSize: 20.0, color: Colors.black87),
                              decoration: InputDecoration(
                                hintText: 'Type a message',
                                filled: true,
                                fillColor: Colors.white.withOpacity(.7),
                                contentPadding: const EdgeInsets.only(
                                    left: 16.0,
                                    bottom: 8.0,
                                    top: 8.0,
                                    right: 16.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50.0),
                                ),
                              )),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: IconButton(
                            onPressed: () => _sendMessage(),
                            icon: const Icon(
                              Icons.send,
                              color: Colors.white,
                            )),
                      )
                    ],
                  ),
                ],
              )),
          Offstage(
            offstage: !emojiShowing,
            child: SizedBox(
                height: size.height / 4,
                child: EmojiPicker(
                  textEditingController: _messageController,
                  onBackspacePressed: _onBackspacePressed,
                  config: Config(
                    columns: 7,
                    // Issue: https://github.com/flutter/flutter/issues/28894
                    emojiSizeMax: 32 *
                        (foundation.defaultTargetPlatform ==
                                TargetPlatform.iOS
                            ? 1.30
                            : 1.0),
                    verticalSpacing: 0,
                    horizontalSpacing: 0,
                    gridPadding: EdgeInsets.zero,
                    // initCategory: Category.RECENT,
                    bgColor: const Color(0xFFF2F2F2),
                    indicatorColor: Colors.teal,
                    iconColor: Colors.grey,
                    iconColorSelected: Colors.teal,
                    backspaceColor: Colors.teal,
                    skinToneDialogBgColor: Colors.white,
                    skinToneIndicatorColor: Colors.grey,
                    enableSkinTones: true,
                    recentTabBehavior: RecentTabBehavior.RECENT,
                    recentsLimit: 28,
                    replaceEmojiOnLimitExceed: false,
                    noRecents: const Text(
                      'No Recents',
                      style: TextStyle(fontSize: 20, color: Colors.black26),
                      textAlign: TextAlign.center,
                    ),
                    loadingIndicator: const SizedBox.shrink(),
                    tabIndicatorAnimDuration: kTabScrollDuration,
                    categoryIcons: const CategoryIcons(),
                    buttonMode: ButtonMode.MATERIAL,
                    checkPlatformCompatibility: true,
                  ),
                )),
          ),
        ],
      ),
    );
  }

  _onBackspacePressed() {
    _messageController
      ..text = _messageController.text.characters.toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _messageController.text.length));
  }
}

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

Widget replayWidget(bool isMe, int? replayto, size) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Container(
        width: isMe ? 0 : 2,
        color: Colors.teal,
        child: const Text(''),
      ),
      Container(
          decoration: BoxDecoration(
              color: Colors.grey.shade200.withOpacity(.7),
              borderRadius: const BorderRadius.all(Radius.circular(5))),
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: SizedBox(
              width: size.width / 5,
              child: Text(
                getReplay(replayto!).content,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
            ),
          )),
      Container(
        width: isMe ? 2 : 0,
        color: Colors.teal,
        child: const Text(''),
      ),
    ],
  );
}

Message getReplay(int id) {
  Message message;
  try {
    message = MessagesModel.messages.singleWhere((element) => element.id == id);
  } catch (e) {
    return Message(id: 0,content: "unable to fine message", sender: 0, seen_by: []);
  }
  return message;
}
