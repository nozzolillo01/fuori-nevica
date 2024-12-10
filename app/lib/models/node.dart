import 'package:web_socket_channel/io.dart';

class Node {
  final String address, name;
  final int id;
  IOWebSocketChannel? channel;
  bool isConnected;

  Node(this.id, this.address, this.name, this.channel) : isConnected = channel != null;

  void sendMessage(String message) {
    channel!.sink.add(message);
  }

  void close() {
    channel!.sink.close();
    isConnected = false;
  }
}
