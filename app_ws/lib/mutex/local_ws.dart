import 'dart:io';

import 'package:fuori_nevica/config.dart';
import 'package:flutter/material.dart';

class LocalWebSocketServer {
  final int port;
  late HttpServer _server;

  LocalWebSocketServer({this.port = Shared.websocketPort});

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.anyIPv4, port);

    _server.listen((HttpRequest request) {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        WebSocketTransformer.upgrade(request).then((WebSocket websocket) {
          debugPrint('Client connesso');
          websocket.listen(
            (message) {
              debugPrint('[wsServer] ricevuto: $message');
              websocket.add('$message'); // Risponde al client
            },
            onDone: () {
              debugPrint('[wsServer] disconnesso');
            },
            onError: (error) {
              debugPrint('[wsServer] errore: $error');
            },
          );
        });
      } else {
        request.response
          ..statusCode = HttpStatus.forbidden
          ..close();
        debugPrint('[wsServer] disconnesso');
      }
    });
  }

  Future<void> stop() async {
    await _server.close();
    debugPrint('[wsServer] stoppato');
  }
}
