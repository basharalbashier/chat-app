import 'package:flutter/material.dart';

import '../helpers/find_message.dart';

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
