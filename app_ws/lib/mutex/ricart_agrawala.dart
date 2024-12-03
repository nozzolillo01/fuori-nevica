import 'dart:convert';

import 'package:fuori_nevica/mutex/communication_manager.dart';
import 'package:fuori_nevica/mutex/node.dart';
import 'package:flutter/material.dart';

class RicartAgrawala {
  final CommunicationManager communicationManager = CommunicationManager();

  int _timestamp;
  Map<int, bool> _replies;

  static final RicartAgrawala _instance = RicartAgrawala._internal();

  factory RicartAgrawala() {
    return _instance;
  }

  RicartAgrawala._internal()
      : _timestamp = 0,
        _replies = {};

  void requestResource() {
    _timestamp++;
    //TODO invia ordine
    final message = jsonEncode({
      'type': 'request',
      'nodeId': communicationManager.nodeId,
      'timestamp': _timestamp,
    });

    communicationManager.multicastMessage(message);
  }

  void handleReply(Map<String, dynamic> data, Node node) {
    _replies[data['nodeId']] = true;
    if (_allRepliesReceived()) {
      _accessResource();
    }
  }

  void handleRequest(Map<String, dynamic> data, Node node) {
    final otherNodeId = data['nodeId'];
    final otherTimestamp = data['timestamp'];

    if (_shouldReplyImmediately(otherTimestamp, otherNodeId)) {
      _sendReply(otherNodeId);
    }
  }

  bool _shouldReplyImmediately(int otherTimestamp, int otherNodeId) {
    return _timestamp > otherTimestamp ||
        (_timestamp == otherTimestamp &&
            communicationManager.nodeId > otherNodeId);
  }

  void _sendReply(int targetNodeId) {
    final reply = jsonEncode({
      'type': 'reply',
      'nodeId': communicationManager.nodeId,
      'timestamp': _instance,
    });

    final targetNode = communicationManager.peers
        .firstWhere((peer) => peer.address.contains(targetNodeId.toString()));
    if (targetNode.isConnected) {
      targetNode.sendMessage(reply);
    }
  }

  bool _allRepliesReceived() => _replies.values.every((v) => v);

  void _accessResource() {
    debugPrint('Accesso alla risorsa con timestamp $_timestamp');
    _replies.clear();
  }
}
