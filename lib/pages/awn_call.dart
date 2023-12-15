import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:peerdart/peerdart.dart';
import 'package:test_client/test_client.dart';

import '../modules/peer_client.dart';

class AwnCall extends StatefulWidget {
  const AwnCall(
      {super.key,
      required this.user,
      required this.to,
      required this.isVideo,
      required this.call});
  final User user;
  final User to;
  final bool isVideo;
  final MediaConnection call;
  @override
  State<AwnCall> createState() => _AwnCallState();
}

class _AwnCallState extends State<AwnCall> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  bool isVideo = false;
  @override
  void initState() {
    isVideo = widget.isVideo;
    awnser(widget.call);

    super.initState();
  }

  awnser(MediaConnection call) async {
    final mediaStream = await navigator.mediaDevices
        .getUserMedia({"video": isVideo, "audio": true});
    call.answer(mediaStream);

    call.on<MediaStream>("stream").listen((event) {
      _localRenderer.srcObject = mediaStream;
      _remoteRenderer.srcObject = event;

      setState(() {
        // inCall = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size? size = MediaQuery.maybeOf(context)?.size;

    return Scaffold(
        // appBar: AppBar(
        //   elevation: 0.0,
        // ),
        backgroundColor: Colors.transparent.withOpacity(.1),
        body: SizedBox(
          height: size!.height,
          width: size.width,
          child: Stack(
            children: [
              isVideo
                  ? SizedBox(
                      height: size.height,
                      width: size.width,
                      child: RTCVideoView(
                        _localRenderer,
                      ),
                    )
                  : Container(
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.deepOrange, Colors.cyan],
                      )),
                      child: Align(
                          alignment: Alignment.center,
                          child: Column(
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: (size.height / size.width) * 50,
                              ),
                              Text(
                                widget.to.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey.shade900),
                              ),
                            ],
                          )),
                    ),
              Positioned(
                  bottom: -10,
                  child: SizedBox(
                    width: size.width,
                    height: size.height / 12,
                    child: Card(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                            onPressed: () => {}, icon: Icon(Icons.mic_rounded)),
                        IconButton(
                            onPressed: () => {},
                            icon: Icon(Icons.speaker_phone_rounded)),
                        IconButton(
                            color: Colors.blue,
                            onPressed: () => {},
                            icon: Icon(Icons.phone_bluetooth_speaker)),
                        IconButton(
                            onPressed: () => setState(() => isVideo = !isVideo),
                            icon: Icon(isVideo
                                ? Icons.videocam_sharp
                                : Icons.videocam_off)),
                        IconButton(
                            color: Colors.red,
                            onPressed: () {
                              PeerClient.peerClient.init(widget.user);
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.call_end))
                      ],
                    )),
                  ))
            ],
          ),
        ));
  }
}
