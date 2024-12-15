import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class Node {
  //TODO migrare la creazione del canale-ws qui
  final String address, name;
  final int id;
  IOWebSocketChannel? channel;
  bool isConnected;

  Node(this.id, this.address, this.name, this.channel)
      : isConnected = channel != null;

  void sendMessage(String message) {
    if (channel == null) {
      isConnected = false;
      return;
    }

    try {
      channel!.sink.add(message);
    } catch (e) {
      isConnected = false;
      debugPrint(e.toString());
    }
  }

  void close() {
    channel!.sink.close();
    isConnected = false;
  }
}
