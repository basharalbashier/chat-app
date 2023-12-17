import 'package:flutter/foundation.dart';
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
  MediaStream? _localStream;
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  bool isVideo = false;
  bool inCall = false;
  void initState() {
    isVideo = widget.isVideo;
    awnser(widget.call);

    super.initState();
  }

  Future<void> _selectAudioOutput(String? deviceId) async {
    if (!inCall) {
      return;
    }
    await _localRenderer.audioOutput(deviceId!);
  }

  var _speakerphoneOn = false;

  Future<void> _setSpeakerphoneOn() async {
    _speakerphoneOn = !_speakerphoneOn;
    await Helper.setSpeakerphoneOn(_speakerphoneOn);
    setState(() {});
  }

  awnser(MediaConnection call) async {
    _localStream = await navigator.mediaDevices
        .getUserMedia({"video": isVideo, "audio": true});
    call.answer(_localStream!);

    call.on<MediaStream>("stream").listen((event) {
      _localRenderer.srcObject = _localStream;
      _remoteRenderer.srcObject = event;

      setState(() {
        inCall = true;
      });
    });
  }

  Future<void> _stop() async {
    try {
      _localStream?.getTracks().forEach((track) async {
        await track.stop();
      });
      await _localStream?.dispose();
      _localStream = null;
      _localRenderer.srcObject = null;
      _remoteRenderer.srcObject = null;
      // senders.clear();
      inCall = false;
      _speakerphoneOn = false;
      await Helper.setSpeakerphoneOn(_speakerphoneOn);
      setState(() {});
      Navigator.of(context).pop();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
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
                            onPressed: () => _setSpeakerphoneOn,
                            icon: Icon(_speakerphoneOn
                                ? Icons.speaker_phone
                                : Icons.phone_android)),
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
                            onPressed: () => _stop(),
                            icon: const Icon(Icons.call_end))
                      ],
                    )),
                  ))
            ],
          ),
        ));
  }
}
