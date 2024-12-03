import 'dart:convert';

import 'package:app_ws/mutex/communication_manager.dart';
import 'package:app_ws/mutex/node.dart';
import 'package:flutter/material.dart';

class RicartAgrawala {
  final CommunicationManager communicationManager = CommunicationManager();

  int timestamp;
  Map<int, bool> replies;

  static final RicartAgrawala _instance = RicartAgrawala._internal();

  factory RicartAgrawala() {
    return _instance;
  }

  RicartAgrawala._internal()
      : timestamp = 0,
        replies = {};

  void requestResource() {
    timestamp++;
    final message = jsonEncode({
      'type': 'request',
      'nodeId': communicationManager.nodeId,
      'timestamp': timestamp,
    });

    communicationManager.multicastMessage(message);
  }

  void handleReply(Map<String, dynamic> data, Node node) {
    replies[data['nodeId']] = true;
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
    return timestamp > otherTimestamp ||
        (timestamp == otherTimestamp &&
            communicationManager.nodeId > otherNodeId);
  }

  void _sendReply(int targetNodeId) {
    final reply = jsonEncode({
      'type': 'reply',
      'nodeId': communicationManager.nodeId,
      'timestamp': timestamp,
    });

    final targetNode = communicationManager.peers
        .firstWhere((peer) => peer.address.contains(targetNodeId.toString()));
    if (targetNode.isConnected) {
      targetNode.sendMessage(reply);
    }
  }

  bool _allRepliesReceived() => replies.values.every((v) => v);

  void _accessResource() {
    debugPrint('Accesso alla risorsa con timestamp $timestamp');
    replies.clear();
  }
}
