import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fuori_nevica/config.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import '../models/node.dart';
import 'ricart_agrawala.dart';

class CommunicationManager {
  int nodeId;
  String nodeName;
  List<Node> peers = [];
  HttpServer? _server;

  void _startServer() async {
    const port = Shared.websocketPort;
    _server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    debugPrint('WebSocket server listening on ws://localhost:$port');

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
      final channel = _createChannel(address);
      final node = Node(id, address, name, channel);
      peers.add(node);

      //TODO message snackbar connessione persa con ...
      /*

ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.red,
                content: Text("Consegna programmata!"),
              ),
            );

      */
      if (channel != null) {
        channel.stream.listen(
          (message) {
            debugPrint('[ws-client] sent to $address: $message');
          },
          onDone: () {
            debugPrint('[ws-client] done $address');
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
    //TODO check if not connected
    for (var peer in peers) {
      peer.sendMessage(message);
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

    //node.close();
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
      return IOWebSocketChannel.connect(
          'ws://$address:${Shared.websocketPort}');
    } catch (e) {
      return null;
    }
  }
}
