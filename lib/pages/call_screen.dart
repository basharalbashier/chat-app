import 'package:chat/modules/show_snackbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:peerdart/peerdart.dart';
import 'package:permission_handler/permission_handler.dart';
import '../modules/peer_client.dart';
import '../widgets/daraggable_widget.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({
    super.key,
    required this.isVideo,
    required this.isCallRec,
    this.call,
  });

  final bool isVideo;
  final bool isCallRec;
  final MediaConnection? call;
  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool isVideo = false;
  bool isAudio = false;

  bool inCall = false;
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  List<MediaDeviceInfo>? _mediaDevicesList = [];
  MediaStream? _localStream;
  final Map<String, FrameCryptor> _frameCyrptors = {};
  String? _selectedVideoInputId;

  @override
  void initState() {
    isVideo = widget.isVideo;
    _localRenderer.initialize();
    _remoteRenderer.initialize();
    makeDevicesReady();
    loadDevices();

    super.initState();
  }

  List<MediaDeviceInfo> get videoInputs => _mediaDevicesList!
      .where((device) => device.kind == 'videoinput')
      .toList();
  List<MediaDeviceInfo> get audioOutputs => _mediaDevicesList!
      .where((device) => device.kind == 'audiooutput')
      .toList();
  Future<void> loadDevices() async {
    if (WebRTC.platformIsAndroid || WebRTC.platformIsIOS) {
      var status = await Permission.bluetooth.request();
      if (status.isPermanentlyDenied) {
        print('BLEpermdisabled');
      }

      status = await Permission.bluetoothConnect.request();
      if (status.isPermanentlyDenied) {
        print('ConnectPermdisabled');
      }
    }
    final devices = await navigator.mediaDevices.enumerateDevices();
    setState(() {
      _mediaDevicesList = devices;
    });
    print(audioOutputs.length.toString() +
        "-------------------------------------------------------------");
  }

  @override
  void dispose() {
    _hangUp();
    super.dispose();
  }

  void _hangUp() async {
    try {
      _localRenderer.srcObject = null;
      _remoteRenderer.srcObject=null;
      await _localRenderer.dispose();
      await _remoteRenderer.dispose();
       // navigator.mediaDevices.ondevicechange = null;
      await Helper.clearAndroidCommunicationDevice();
      Navigator.of(context).pop();
      showSnackbar("HANGING UP >>>>>>>");
    } catch (e) {
      showSnackbar(e.toString());
      Navigator.of(context).pop();
    }
  }

  void _changeScreens() => setState(() => screenCase = !screenCase);

  bool screenCase = false;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
        body: Stack(
      fit: StackFit.expand,
      children: [
        if (isVideo)
          largScreen(
              context,
              screenCase
                  ? localStreamWidget(context, ready, _localRenderer)
                  : remoteStramWidget(_remoteRenderer, inCall)),
        if (isVideo)
          GestureDetector(
              onTap: () => _changeScreens(),
              child: StatefulDragArea(
                  child: smallScreens(
                      context,
                      !screenCase
                          ? localStreamWidget(context, ready, _localRenderer)
                          : remoteStramWidget(_remoteRenderer, inCall)))),
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
                      icon: const Icon(Icons.switch_camera_rounded),
                      onPressed: _toggleVideoInput),
                  IconButton(
                      onPressed: () {
                        setState(() => isVideo = !isVideo);
                      },
                      icon:
                          Icon(isVideo ? Icons.videocam : Icons.videocam_off)),
                  IconButton(
                      color: Colors.red,
                      onPressed: () => _hangUp(),
                      icon: const Icon(Icons.call_end))
                ],
              )),
            )),
        // const BackButton(),
      ],
    ));
  }

  bool ready = false;

  void makeDevicesReady() async {
    final mediaStream = await navigator.mediaDevices
        .getUserMedia({"video": isVideo, "audio": true});
    _localRenderer.srcObject = mediaStream;
    !isVideo ? _localRenderer.audioOutput("0") : null;
    setState(() {
      ready = true;
    });

    widget.isCallRec ? recieve(mediaStream) : call(mediaStream);
  }

  call(mediaStream) {
    final conn = PeerClient.client.peer!
        .call(PeerClient.client.to.value.uid!, mediaStream);

    conn.on("close").listen((event) {
      setState(() {
        mediaStream.dispose();
        inCall = false;
      });
      _hangUp();
    });

    conn.on<MediaStream>("stream").listen((event) async {
      _remoteRenderer.srcObject = event;

      // print("-----------starting----------------------");
      setState(() {
        inCall = true;
      });
      // print("-----------ending------------$inCall----------");
/////////////////////////////////////////////////////////////////////////////////////
    });
  }

  void _toggleVideoInput() async {
    _selectedVideoInputId =
        _selectedVideoInputId == _mediaDevicesList![0].deviceId
            ? _mediaDevicesList![1].deviceId
            : _selectedVideoInputId == _mediaDevicesList![1].deviceId
                ? _mediaDevicesList![0].deviceId
                : _mediaDevicesList![1].deviceId;

    _localRenderer.srcObject = null;

    _localStream?.getTracks().forEach((track) async {
      await track.stop();
    });
    await _localStream?.dispose();

    var newLocalStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {
        if (_selectedVideoInputId != null && kIsWeb)
          'deviceId': _selectedVideoInputId,
        if (_selectedVideoInputId != null && !kIsWeb)
          'optional': [
            {'sourceId': _selectedVideoInputId}
          ],
      },
    });
    _localStream = newLocalStream;
    _localRenderer.srcObject = _localStream;
  }

  recieve(MediaStream mediaStream) {
    widget.call!.answer(mediaStream);
    widget.call!.on("close").listen((event) {
      setState(() {
        mediaStream.dispose();
        inCall = false;
      });
      _hangUp();
    });

    widget.call!.on<MediaStream>("stream").listen((event) {
      _remoteRenderer.srcObject = event;

      setState(() {
        inCall = true;
      });
    });
  }
}

Widget largScreen(BuildContext context, Widget child) {
  var size = MediaQuery.of(context).size;
  return SizedBox(
    height: size.height,
    width: size.width,
    child: child,
  );
}

Widget smallScreens(BuildContext context, Widget child) {
  var size = MediaQuery.of(context).size;
  return SizedBox(
    height: size.height / 4,
    width: size.width / 3,
    child: child,
  );
}

/**
 *             Positioned(
                bottom: 0,
                child: IconButton(
                    icon: const Icon(Icons.switch_camera_rounded),
                    onPressed: change))
 */
Widget localStreamWidget(
    BuildContext context, bool ready, RTCVideoRenderer localRenderer) {
  return ready
      ? RTCVideoView(
          localRenderer,
          mirror: true,
          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
        )
      : const Center(
          child: CircularProgressIndicator.adaptive(),
        );
}

Widget remoteStramWidget(RTCVideoRenderer remoteRenderer, bool inCall) {
  return !inCall
      ? const Card(
          color: Colors.pink,
        )
      : RTCVideoView(
          remoteRenderer,
          mirror: true,
          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
        );
}
