import 'package:app_ws/mutex/ricart_agrawala.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'node.dart';
import 'package:app_ws/config.dart';

class CommunicationManager {
  int nodeId;
  String nodeName;
  List<Node> peers = [];

  static final CommunicationManager _instance =
      CommunicationManager._internal();

  factory CommunicationManager() {
    return _instance;
  }

  CommunicationManager._internal()
      : nodeId = 0,
        nodeName = 'SCONOSCIUTO',
        peers = [];

  void addNode(String address, {String name = 'SCONOSCIUTO'}) {
    try {
      final channel = _createChannel(address);
      final node = Node(address, name, channel);
      peers.add(node);

      //TODO message snackbar connessione persa con ...
      channel.stream.listen(
        (message) {
          _handleMessage(message, node);
        },
        onDone: () {
          node.isConnected = false;
        },
        onError: (error) {
          node.isConnected = false;
        },
      );
    } catch (e) {
      debugPrint('Errore connessione a $address: $e');
    }
  }

  void multicastMessage(String message) {
    for (var peer in peers) {
      if (peer.isConnected) {
        peer.sendMessage(message);
      }
    }
  }

  Future<void> notifyJoin() async {
    final message = jsonEncode({
      'type': 'join',
      'nodeId': nodeId,
      'nodeName': nodeName,
      'nodeAddress': await Shared.getIpAddress(),
    });

    multicastMessage(message);
  }

  void _handleMessage(String message, Node node) {
    final data = jsonDecode(message);

    if (data['type'] == 'join') {
      //TODO check if already exists
      addNode(data['nodeAddress'], name: data['nodeName']);
    } else if (data['type'] == 'request') {
      RicartAgrawala().handleRequest(data, node);
    } else if (data['type'] == 'reply') {
      RicartAgrawala().handleReply(data, node);
    }
  }

  IOWebSocketChannel _createChannel(String address) {
    return IOWebSocketChannel.connect('ws://$address:${Shared.websocketPort}');
  }
}
