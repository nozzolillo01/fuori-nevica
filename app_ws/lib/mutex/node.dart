import 'package:web_socket_channel/io.dart';

class Node {
  final String address, name;
  final IOWebSocketChannel channel;
  bool isConnected;

  Node(this.address, this.name, this.channel) : isConnected = true;

  void sendMessage(String message) {
    channel.sink.add(message);
  }

  void close() {
    channel.sink.close();
    isConnected = false;
  }
}
