import 'package:chat/controllers/db_controller.dart';
import 'package:chat/controllers/notification_controller.dart';
import 'package:chat/modules/show_snackbar.dart';
import 'package:peerdart/peerdart.dart';
import 'package:test_client/test_client.dart';
import '../helpers/constant.dart';
import '../pages/new_call.dart';

class PeerClient {
  PeerClient._();
  static final PeerClient client = PeerClient._();
  Peer? peer;
  DataConnection? dataConnection;
  bool inCall = false;
  User? me;
  List<String> connectedPeers = [];
  Future<void> init(User user) async {
    me = user;

    try {
      peer = Peer(
          id: me!.uid.toString(),
          options: PeerOptions(
            secure: false,
            host: host,
            port: 8080,
            path: "/peer",
            // debug: LogLevel.All,
          ));

      peer!.on<MediaConnection>("call").listen((call) async {
        showCallDialog(User(name: "name"), call);
      });
      peer!.on<DataConnection>("connection").listen((event) async {
        showSnackbar("${event.peer} is connected ..");
        dataConnection = event;
        bool isConnected = connectedPeers.contains(peer);

        !isConnected
            ? connectedPeers.add(dataConnection!.peer)
            : dataConnection!.close();

        dataConnection!.on("data").listen((data) {
          recievedData(data);
        });

        dataConnection!.on("binary").listen((data) {});

        dataConnection!.on("close").listen((data) {
          showSnackbar("${event.peer} is disconnected ..");

          connectedPeers.remove(dataConnection!.peer);
        });
      });
    } catch (e) {
      showSnackbar(e.toString());
    }
  }

  Future<void> connect(String peer) async {
    bool isConnected = connectedPeers.contains(peer);
    if (isConnected) {
      showSnackbar("$peer is Connected");
    } else {
      showSnackbar("Connecting to $peer");

      try {
        dataConnection = PeerClient.client.peer!.connect(peer);
        dataConnection!.on("open").listen((event) {
          connectedPeers.add(peer);
          connectedPeers = connectedPeers.toSet().toList();

          dataConnection!.on("close").listen((event) {
            connectedPeers.remove(peer);
          });
          dataConnection!.on("data").listen((data) => recievedData(data));
          dataConnection!.on("binary").listen((data) {});
        });
        dataConnection!.on("close").listen((event) {
          connectedPeers.remove(peer);
        });
      } catch (e) {
        showSnackbar(e.toString());
      }
    }
  }

  dispose() async {
    // try {
    //   peer = Peer();
    //   peer!.controller.close();
    //   peer!.dispose();
    // } catch (e) {}
  }

  sendMessageToPeer(Message message) async {
    bool isConnected = connectedPeers.contains(message.channel);
    if (isConnected) {
      try {
        await dataConnection!.send(message.content);
        await DBProvider.db.addMessage(message, true);
        await DBProvider.db.listMessages();
      } catch (e) {
        await DBProvider.db.addMessage(message, false);
        await DBProvider.db.listMessages();
        showSnackbar(e.toString());
      }
    } else {

      // await DBProvider.db.addMessage(message, false);
      // await DBProvider.db.listMessages();
      await connect(message.channel!);
    }
  }

  void recievedData(data) {
    var message = Message(
        content: data,
        seen_by: [],
        channel: dataConnection!.peer,
        send_by: dataConnection!.peer,
        sent_at: DateTime.now());
    DBProvider.db.addMessage(message, null);
    DBProvider.db.listMessages();
    NotificationController.notificationController
        .showNotificationWithActions(message);
    // previeusMessage = data;
  }
}
