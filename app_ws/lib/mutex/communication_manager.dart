import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'node.dart';
import 'package:app_ws/config.dart';

class CommunicationManager {
  final int nodeId;
  final String nodeName;
  int timestamp = 0;
  final List<Node> peers = [];
  final Map<int, bool> replies = {};

  CommunicationManager(
      this.nodeId, this.nodeName, List<Map<String, dynamic>> peers) {
    for (var peer in peers) {
      _initNode(peer['indirizzo'], name: peer['nome']);
    }
  }

  void requestResource() {
    timestamp++;
    final message = jsonEncode({
      'type': 'request',
      'nodeId': nodeId,
      'timestamp': timestamp,
    });

    multicastMessage(message);
  }

  Future<void> notifyRegistration() async {
    debugPrint(
        "/**************************************** entered notifying registration");
    final message = jsonEncode({
      'type': 'registration',
      'nodeId': nodeId,
      'nodeName': nodeName,
      'nodeAddress': await Config.getIpAddress(),
    });

    multicastMessage(message);
  }

  void multicastMessage(String message) {
    debugPrint("/**************************************** multicasting to");
    for (var peer in peers) {
      if (peer.isConnected) {
        debugPrint("/**************************************** ${peer.address}");
        peer.sendMessage(message);
      }
    }
  }

  void _initNode(String address, {String name = 'SCONOSCIUTO'}) {
    debugPrint('Connettendo a $address...');
    try {
      final channel = _createChannel(address);
      debugPrint('Connesso a $address');

      final node = Node(address, name, channel);
      peers.add(node);

      channel.stream.listen(
        (message) {
          _handleIncomingMessage(message, node);
        },
        onDone: () {
          node.isConnected = false;
          debugPrint('Connessione chiusa con $address');
        },
        onError: (error) {
          node.isConnected = false;
          debugPrint('Errore connessione a $address: $error');
        },
      );
    } catch (e) {
      debugPrint('Errore connessione a $address: $e');
    }
  }

  IOWebSocketChannel _createChannel(String address) {
    return IOWebSocketChannel.connect('ws://$address:${Config.websocketPort}');
  }

  void _handleIncomingMessage(String message, Node node) {
    final data = jsonDecode(message);

    if (data['type'] == 'registration') {
      //TODO check if already exists
      _initNode(data['nodeAddress'], name: data['nodeName']);
      return;
    }

    //ELSE: request or reply
    timestamp =
        (timestamp > data['timestamp'] ? timestamp : data['timestamp']) + 1;

    if (data['type'] == 'request') {
      _handleRequest(data, node);
    } else if (data['type'] == 'reply') {
      replies[data['nodeId']] = true;
      if (allRepliesReceived()) {
        accessResource();
      }
    }
  }

  void _handleRequest(Map<String, dynamic> data, Node node) {
    final otherNodeId = data['nodeId'];
    final otherTimestamp = data['timestamp'];

    if (_shouldReplyImmediately(otherTimestamp, otherNodeId)) {
      _sendReply(otherNodeId);
    }
  }

  bool _shouldReplyImmediately(int otherTimestamp, int otherNodeId) {
    return timestamp > otherTimestamp ||
        (timestamp == otherTimestamp && nodeId > otherNodeId);
  }

  void _sendReply(int targetNodeId) {
    final reply = jsonEncode({
      'type': 'reply',
      'nodeId': nodeId,
      'timestamp': timestamp,
    });

    final targetNode = peers
        .firstWhere((peer) => peer.address.contains(targetNodeId.toString()));
    if (targetNode.isConnected) {
      targetNode.sendMessage(reply);
    }
  }

  bool allRepliesReceived() => replies.values.every((v) => v);

  void accessResource() {
    debugPrint('Accesso alla risorsa con timestamp $timestamp');
    replies.clear();
  }

  List<Node> getConnectedPeers() {
    return peers;
  }

  Future<void> refreshNodes() async {
    for (var peer in peers) {
      try {
        await peer.channel.ready;
        peer.isConnected = true;
      } catch (e) {
        peer.isConnected = false;
      }
    }
  }
}
