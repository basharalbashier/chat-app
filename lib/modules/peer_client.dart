
import 'package:get/get.dart';
import 'package:peerdart/peerdart.dart';
import '../client/message.dart';
import '../client/user.dart';
import '../controllers/db_controller.dart';
import '../controllers/notification_controller.dart';
import '../helpers/constant.dart';
import '../pages/new_call.dart';
import 'show_snackbar.dart';

class PeerClient {
  PeerClient._();
  static final PeerClient client = PeerClient._();
  Peer? peer;
  DataConnection? dataConnection;
  bool inCall = false;
  User? me;
  var to = User(name: "name").obs;
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
            debug: LogLevel.All,
          ));

      peer!.on<MediaConnection>("call").listen((call) async {
        showCallDialog(User(name: "name"), call);
      });
      peer!.on<DataConnection>("connection").listen((event) async {
        User user = await DBProvider.db.getUser(event.peer);
        _handleConnection(user);
      });
    } catch (e) {
      showSnackbar(e.toString());
    }
  }

  Future<void> connect(String peer) async {
    User user = await DBProvider.db.getUser(peer);

    bool isConnected = connectedPeers.contains(peer);
    if (isConnected) {
      DBProvider.db.setUserOnlineOrLastSeen(user, true);

      showSnackbar("$peer is Connected");
    } else {
      try {
        dataConnection = PeerClient.client.peer!.connect(peer);
        showSnackbar("Connecting to $peer");
        dataConnection!.on("open").listen((event) {
          _handleConnection(user);
        });
        dataConnection!.on("close").listen((event) {
          DBProvider.db.setUserOnlineOrLastSeen(user, false);
          showSnackbar("Unable to connect to $peer");
          connectedPeers.remove(peer);
        });
      } catch (e) {
        showSnackbar("Unable to connect to $peer \n $e");

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

  void _handleConnection(User user) {
    DBProvider.db.setUserOnlineOrLastSeen(user, true);

    connectedPeers.add(user.uid!);
    connectedPeers = connectedPeers.toSet().toList();

    dataConnection!.on("close").listen((event) {
      DBProvider.db.setUserOnlineOrLastSeen(user, false);

      connectedPeers.remove(peer);
    });
    dataConnection!.on("data").listen((data) => recievedData(data));
    dataConnection!.on("binary").listen((data) {});
  }
}
