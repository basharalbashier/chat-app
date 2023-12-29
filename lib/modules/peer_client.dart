import 'package:chat/modules/show_snackbar.dart';
import 'package:peerdart/peerdart.dart';
import 'package:test_client/test_client.dart';
import '../helpers/constant.dart';
import '../pages/new_call.dart';

class PeerClient {
  PeerClient._();
  static final PeerClient client = PeerClient._();
  Peer? peer;

  bool inCall = false;
  User? me;
  Future<void> init() async {
    try {
      peer = Peer(
          id: me!.uid.toString(),
          options: PeerOptions(
            secure: false,
            host: host,
            port: 8080,
            path: "/peer",
          ));
      peer!.reconnect();
    } catch (e) {
      await dispose();
      init();
    }

    peer!.on<MediaConnection>("call").listen((call) async {
      showCallDialog(User(name: "name"), call);
    });
    peer!.on<DataConnection>("connection").listen((event) async {
      event.on("data").listen((data) {
        showSnackbar(event.peer);
      });
    });
  }

  dispose() async {
    try {
      peer = Peer(
          id: me!.uid.toString(),
          options: PeerOptions(
            secure: false,
            host: host,
            port: 8080,
            path: "/peer",
          ));
      peer!.dispose();
    } catch (e) {}
  }
}
