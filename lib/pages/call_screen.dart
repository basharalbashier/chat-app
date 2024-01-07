import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:peerdart/peerdart.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:test_client/test_client.dart';

import '../modules/peer_client.dart';
import '../widgets/daraggable_widget.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({
    super.key,
    required this.to,
    required this.isVideo,
  });

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
  List<MediaDeviceInfo>? _mediaDevicesList = [];
  MediaStream? _localStream;
  final Map<String, FrameCryptor> _frameCyrptors = {};
  String? _selectedVideoInputId;

  @override
  void initState() {
    isVideo = widget.isVideo;
    _localRenderer.initialize();

    connect();
    loadDevices();

    super.initState();
  }

  List<MediaDeviceInfo> get videoInputs => _mediaDevicesList!
      .where((device) => device.kind == 'videoinput')
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
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _localRenderer.srcObject!.dispose();

    navigator.mediaDevices.ondevicechange = null;
    super.dispose();
  }

  void _hangUp(bool isVideo) async {
    try {
      _localStream?.getTracks().forEach((track) => track.stop());

      _localRenderer.srcObject = null;
    } catch (e) {
      print(e.toString());
    }
  }

  void _changeScreens() => setState(() => screenCase = !screenCase);

  bool screenCase = false;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
        body: Stack(
      children: [
        largScreen(
            context,
            screenCase
                ? localStreamWidget(context, ready, _localRenderer)
                : remoteStramWidget()),
        GestureDetector(
            onTap: () => _changeScreens(),
            child: StatefulDragArea(
                child: smallScreens(
                    context,
                    !screenCase
                        ? localStreamWidget(context, ready, _localRenderer)
                        : remoteStramWidget()))),
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
                      onPressed: () => {},
                      icon: const Icon(Icons.call_end))
                ],
              )),
            )),
        const BackButton(),
      ],
    ));
  }

  bool ready = false;

  void connect() async {
    final mediaStream = await navigator.mediaDevices
        .getUserMedia({"video": isVideo, "audio": true});
    _localRenderer.srcObject = mediaStream;
    setState(() {
      ready = true;
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

Widget remoteStramWidget() {
  return const Card(
    color: Colors.pink,
  );
}
