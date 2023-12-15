import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:peerdart/peerdart.dart';
import 'package:test_client/test_client.dart';

import '../modules/peer_client.dart';

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
  bool isAudio = false;

  bool inCall = false;
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  List<MediaDeviceInfo>? _mediaDevicesList;
  MediaStream? _localStream;
  final Map<String, FrameCryptor> _frameCyrptors = {};

  @override
  void initState() {
    isVideo = widget.isVideo;
    _localRenderer.initialize();
    _remoteRenderer.initialize();
    _makeCall;
    navigator.mediaDevices.ondevicechange = (event) async {
      print('++++++ ondevicechange ++++++');
      _mediaDevicesList = await navigator.mediaDevices.enumerateDevices();
    };
    connect();
    super.initState();
  }

  @override
  void deactivate() {
    super.deactivate();
    if (inCall) {
      _hangUp(isVideo);
    }
    _localRenderer.dispose();
    navigator.mediaDevices.ondevicechange = null;
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  void _stopAudio() async {
    _frameCyrptors.removeWhere((key, value) {
      if (key.startsWith('audio')) {
        value.dispose();
        return true;
      }
      return false;
    });
    await _removeExistingAudioTrack(fromConnection: true);
    // await _negotiate();
    setState(() {
      // _micOn = false;
    });
  }

  Future<void> _removeExistingAudioTrack({bool fromConnection = false}) async {
    var tracks = _localStream!.getAudioTracks();
    for (var i = tracks.length - 1; i >= 0; i--) {
      var track = tracks[i];
      if (fromConnection) {
        await _connectionRemoveTrack(track);
      }
      await _localStream!.removeTrack(track);
      await track.stop();
    }
  }

  Future<void> _connectionRemoveTrack(MediaStreamTrack track) async {
    // var sender = track.kind == 'video' ? _videoSender : _audioSender;
    // if (sender != null) {
    //   print('Have a Sender of kind:${track.kind}');
    //   var trans = await _getSendersTransceiver(sender.senderId);
    //   if (trans != null) {
    //     print('Setting direction and replacing track with null');
    //     await trans.setDirection(TransceiverDirection.Inactive);
    //     await trans.sender.replaceTrack(null);
    //   }
    // }
  }
  Future<RTCRtpTransceiver?> _getSendersTransceiver(String senderId) async {
    RTCRtpTransceiver? foundTrans;
    // var trans = await PeerClient.peerClient.peer?.getTransceivers();
    // for (var tran in trans) {
    //   if (tran.sender.senderId == senderId) {
    //     foundTrans = tran;
    //     break;
    //   }
    // }
    return foundTrans;
  }

  void _makeCall() async {
    final mediaConstraints = <String, dynamic>{
      'audio': true,
      'video': {
        'mandatory': {
          // 'minWidth':
          //     '${size.width}', // Provide your own width, height and frame rate here
          // 'minHeight': '${size.height}',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      }
    };

    try {
      var stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _mediaDevicesList = await navigator.mediaDevices.enumerateDevices();
      _localStream = stream;
      _localRenderer.srcObject = _localStream;
    } catch (e) {
      print(e.toString());
    }
    if (!mounted) return;

    // setState(() {
    //   _inCalling = true;
    // });
  }

  void _hangUp(bool isVideo) async {
    try {
      // if (kIsWeb) {
      _localStream?.getTracks().forEach((track) => track.stop());
      // }
      // await _localStream?.dispose();
      _localRenderer.srcObject = null;
      // setState(() {
      //   _inCalling = false;
      // });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (_localRenderer.srcObject == null && isVideo) {
      return Center(
        child: CircularProgressIndicator.adaptive(),
      );
    }
    return Scaffold(
        // appBar: AppBar(
        //   elevation: 0.0,
        // ),
        backgroundColor: Colors.transparent.withOpacity(.1),
        body: Stack(
          children: [
            isVideo
                ? RTCVideoView(
                    _localRenderer,
                    mirror: true,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
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
                          onPressed: () => {},
                          icon: Icon(isAudio ? Icons.mic : Icons.mic_off)),
                      IconButton(
                          onPressed: () => {},
                          icon: Icon(Icons.speaker_phone_rounded)),
                      IconButton(
                          color: Colors.blue,
                          onPressed: () => {},
                          icon: Icon(Icons.phone_bluetooth_speaker)),
                      IconButton(
                          onPressed: () {
                            setState(() => isVideo = !isVideo);
                            _hangUp(isVideo);
                          },
                          icon: Icon(
                              isVideo ? Icons.videocam : Icons.videocam_off)),
                      IconButton(
                          color: Colors.red,
                          onPressed: closeConnection,
                          icon: const Icon(Icons.call_end))
                    ],
                  )),
                ))
          ],
        ));
  }

  void closeConnection() {
    Navigator.of(context).pop();
  }

  void connect() async {
    final mediaStream = await navigator.mediaDevices
        .getUserMedia({"video": isVideo, "audio": true});
    _localRenderer.srcObject = mediaStream;

    var conn =
        PeerClient.peerClient.peer!.call(widget.to.id.toString(), mediaStream);
    conn.options!.constraints = {
      // "offerToReceiveAudio": true,
      // "offerToReceiveVideo": true,
    };
    conn.answer(mediaStream);

    conn.on("close").listen((event) {
      setState(() {
        inCall = false;
        mediaStream.dispose();
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
