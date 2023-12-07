import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:peerdart/peerdart.dart';
import 'package:test_client/test_client.dart';
import 'package:test_flutter/modules/peer_client.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({
    super.key,
    required this.user,
    required this.to,
    required this.isVideo,
  });
  final User user;
  // final Peer peer;
  final User to;
  final bool isVideo;
  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool isVideo = false;
  bool inCall = false;
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  @override
  void initState() {
    isVideo = widget.isVideo;
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    connect();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
                            onPressed: closeConnection,
                            icon: const Icon(Icons.call_end))
                      ],
                    )),
                  ))
            ],
          ),
        ));
  }

  void closeConnection() {
    Navigator.of(context).pop();
  }

  void connect() async {
    final mediaStream = await navigator.mediaDevices
        .getUserMedia({"video": isVideo, "audio": true});

    var conn =
        PeerClient.peerClient.peer!.call(widget.to.id.toString(), mediaStream);
    conn.options!.constraints = {
      "offerToReceiveAudio": true,
      "offerToReceiveVideo": true,
    };
    conn.answer(mediaStream);

    conn.on("close").listen((event) {
      setState(() {
        inCall = false;
      });
    });

    conn.on<MediaStream>("stream").listen((event) {
      _remoteRenderer.srcObject = event;
      _localRenderer.srcObject = mediaStream;
      setState(() {
        inCall = true;
      });
    });
  }
}
