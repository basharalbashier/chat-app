import 'package:flutter/material.dart';
import 'package:test_client/test_client.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key, required this.user, required this.to});
  final User user;
  final User to;
  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  @override
  Widget build(BuildContext context) {
    Size? size = MediaQuery.maybeOf(context)?.size;

    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
        ),
        backgroundColor: Colors.transparent.withOpacity(.1),
        body: SizedBox(
          height: size!.height,
          width: size.width,
          child: Stack(
            children: [
              Container(
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
                          radius: (size.height/size.width)*50,
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
                            onPressed: () => {},
                            icon: Icon(Icons.video_call_rounded)),
                        IconButton(
                            color: Colors.red,
                            onPressed: () => {},
                            icon: Icon(Icons.call_end))
                      ],
                    )),
                  ))
            ],
          ),
        ));
  }
}
