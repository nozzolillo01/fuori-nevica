import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fuori_nevica/config.dart';
import 'package:fuori_nevica/services/webservice.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import '../models/node.dart';
import '../mutex/ricart_agrawala.dart';

class CommunicationManager {
  int wsPort = Shared.websocketPort;

  int nodeId;
  String nodeName;
  List<Node> peers = [];
  HttpServer? _server;

  void _startServer() async {
    _server = await HttpServer.bind(InternetAddress.anyIPv4, wsPort);
    debugPrint('[ws-server] started');

    _server?.listen((HttpRequest request) async {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        WebSocket socket = await WebSocketTransformer.upgrade(request);

        socket.listen(
          (message) {
            debugPrint('[ws-server] received : $message');
            _handleMessage(message);
          },
          onDone: () {
            debugPrint('[ws-server] anyone disconnected');
          },
          onError: (error) {
            debugPrint('[ws-server] error : $error');
          },
        );
      } else {
        request.response.statusCode = HttpStatus.forbidden;
        request.response.close();
      }
    });
  }

  void reset() {
    _server?.close(force: true);
    peers.clear();
  }

  static final CommunicationManager _instance =
      CommunicationManager._internal();

  factory CommunicationManager() {
    return _instance;
  }

  CommunicationManager._internal()
      : nodeId = 0,
        nodeName = 'SCONOSCIUTO',
        peers = [] {
    _startServer();
  }

  void addNode(int id, String address, {String name = 'SCONOSCIUTO'}) {
    try {
      if (peers.any((p) => p.address == address)) {
        removeNode(address);
      }

      final channel = _createChannel(address);
      final node = Node(id, address, name, channel);
      peers.add(node);

      if (channel != null) {
        channel.stream.listen(
          (message) {
            debugPrint('[ws-client] sent to $address: $message');
          },
          onDone: () {
            debugPrint('[ws-client] closed $address');
            node.isConnected = false;
          },
          onError: (error) {
            debugPrint('[ws-client] error from $address: $error');
            node.isConnected = false;
          },
        );
      }
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

  void refreshPeers() async {
    final knownPeers = await WebService().getCamerieri();

    //TODO eliminare i nodi non più presenti
    for (var peer in knownPeers) {
      if (peer['indirizzo'] == await Shared.getIpAddress()) continue;
      if (peers.map((p) => p.address).contains(peer['indirizzo'])) continue;

      addNode(peer['id'], peer['indirizzo'], name: peer['nome']);
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

  void removeNode(String address) {
    if (!peers.any((p) => p.address == address)) return;

    //TODO node.close();
    peers.removeWhere((p) => p.address == address);
  }

  Future<void> _handleMessage(String message) async {
    final data = jsonDecode(message);

    if (data['nodeAddress'] == await Shared.getIpAddress()) {
      return;
    }

    if (data['type'] == 'join') {
      removeNode(data['nodeAddress']);
      addNode(data['nodeId'], data['nodeAddress'], name: data['nodeName']);
    } else if (data['type'] == 'request') {
      RicartAgrawala().receiveRequest(data);
    } else if (data['type'] == 'reply') {
      RicartAgrawala().receiveReply(data);
    }
  }

  IOWebSocketChannel? _createChannel(String address) {
    try {
      return IOWebSocketChannel.connect('ws://$address:$wsPort');
    } catch (e) {
      return null;
    }
  }
}
