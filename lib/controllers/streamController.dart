import 'dart:async';

class StreamSocket {
  final _socketResponse = StreamController();

  void Function(dynamic) get addResponse => _socketResponse.sink.add;

  Stream get getResponse => _socketResponse.stream;

  void dispose() {
    _socketResponse.close();
  }
}
