import 'package:flutter/foundation.dart';
import 'package:test_client/test_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:test_flutter/pages/chat_screen.dart';
import 'package:test_flutter/pages/list_users.dart';

// Sets up a singleton client object that can be used to talk to the server from
// anywhere in our app. The client is generated from your server code.
// The client is set up to connect to a Serverpod running on a local server on
// the default port. You will need to modify this to connect to staging or
// production servers.
int id =kIsWeb? 2:1;
String name = DateTime.now().second.toString();
String url='http://localhost:8080/';
var client =Client(url);
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Serverpod Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home:  ListUsers(user: User(id:id,name: name ),),
    );
  }
}
