import 'package:chat/controllers/db_controller.dart';
import 'package:chat/modules/peer_client.dart';
import 'package:chat/modules/show_snackbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:peerdart/peerdart.dart';
import 'package:test_client/test_client.dart';

import '../helpers/router.dart';
import '../modules/message.dart';
import '../widgets/message_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.to});

  final User to;

  @override
  State<ChatScreen> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ChatScreen> {
  User? me = PeerClient.client.me;
  final TextEditingController _messageController = TextEditingController();
  ScrollController? _controller;

  bool emojiShowing = false;

  @override
  void initState() {
    PeerClient.client.connect(widget.to.uid!);
    _controller = ScrollController();
    print(PeerClient.client.connectedPeers);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Message? replyMessage;

  onRole() {
    _controller!.animateTo(
      _controller!.position.minScrollExtent,
      duration: const Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
    );
  }

  void _sendMessage() {
    String messageText = _messageController.text.trim();
    if (messageText != '') {
      Message message = Message(
          channel: widget.to.uid,
          content: messageText,
          send_by: me!.uid,
          replayto: replyMessage != null ? replyMessage!.id : null,
          sent_at: DateTime.now(),
          seen_by: []);

      PeerClient.client.sendMessageToPeer(message);
    }
  }

  void sendMessage() async {
    String messageText = _messageController.text.trim();
    if (messageText != '') {
      Message message = Message(
          channel: widget.to.uid,
          content: messageText,
          send_by: me!.uid,
          replayto: replyMessage != null ? replyMessage!.id : null,
          sent_at: DateTime.now(),
          seen_by: []);

      await DBProvider.db.addMessage(message, true);
      await DBProvider.db.listMessages();

      _messageController.text = '';
      replyMessage = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size? size = MediaQuery.maybeOf(context)?.size;
    var messagesModel = Get.put(MessagesModel()).messages;

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Stack(
              fit: StackFit.loose,
              children: [
                TextButton(
                    onPressed: () => onRole(),
                    child: Text(
                      widget.to.name,
                    )),
              ],
            ),
            Row(
              children: [
                IconButton(
                    onPressed: () => move(
                          context,
                          true,
                          Container(),
                        ),
                    icon: const Icon(Icons.call)),
                IconButton(
                    onPressed: () => move(context, true, Container()),
                    icon: const Icon(Icons.video_call))
              ],
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: Obx(
            () => ListView.builder(
              controller: _controller,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              reverse: true,
              cacheExtent: 1000,
              itemCount: messagesModel.length,
              itemBuilder: (BuildContext context, int index) {
                Message message =
                    messagesModel[messagesModel.length - index - 1];

                return message.channel == widget.to.uid
                    ? Dismissible(
                        confirmDismiss: (direction) async {
                          setState(() {
                            replyMessage = message;
                          });
                          return false;
                        },
                        key: Key(message.toString()),
                        child: (message.send_by == PeerClient.client.me!.uid)
                            ? myMessage(message, true, size)
                            : myMessage(message, false, size))
                    : Container();
              },
            ),
          )),
          Container(
              color: Colors.white.withOpacity(.7),
              child: Column(
                children: [
                  Visibility(
                      visible: replyMessage != null,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10, left: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Reply for",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
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
                            child: Divider(color: Colors.grey),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: SizedBox(
                                  width: size!.width - 20,
                                  child: Text(
                                    replyMessage?.content ?? "",
                                    style: const TextStyle(color: Colors.grey),
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
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: TextField(
                              onSubmitted: ((value) => _sendMessage),
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
                            onPressed: _sendMessage,
                            icon: const Icon(
                              Icons.send,
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
                child: Container(),
              )),
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
