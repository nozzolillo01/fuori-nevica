import 'dart:convert';

import 'package:fuori_nevica/mutex/communication_manager.dart';
import 'package:fuori_nevica/mutex/mutex_state.dart';

class RicartAgrawala {
  final CommunicationManager communicationManager = CommunicationManager();

  int _timestamp;
  List<String> _replies;
  MutexState _state;

  static final RicartAgrawala _instance = RicartAgrawala._internal();

  factory RicartAgrawala() {
    return _instance;
  }

  RicartAgrawala._internal()
      : _timestamp = 0,
        _replies = [],
        _state = MutexState.released;

  void requestResource() {
    _state = MutexState.wanted;
    _timestamp++;

    final message = jsonEncode({
      'type': 'request',
      'nodeId': communicationManager.nodeId,
      'timestamp': _timestamp,
    });

    communicationManager.multicastMessage(message);
    //TODO wait until all replies are received
  }

  void handleReply(Map<String, dynamic> data) {
    _replies.add(data['nodeId']);
    if (_allRepliesReceived()) {
      _accessResource();
    }
  }

  void handleRequest(Map<String, dynamic> data) {
    final otherNodeId = data['nodeId'];
    final otherTimestamp = data['timestamp'];

    if (_shouldReplyImmediately(otherTimestamp, otherNodeId)) {
      _sendReply(otherNodeId);
      //TODO else add to queue
    }
  }

  bool _shouldReplyImmediately(int otherTimestamp, int otherNodeId) {
    //se sono in HELD oppure in WANTED e il timestamp è minore
    return !(_state == MutexState.held ||
        (_state == MutexState.wanted && otherTimestamp < otherNodeId));
  }

  void _sendReply(int targetNodeId) {
    final reply = jsonEncode({
      'type': 'reply',
      'nodeId': communicationManager.nodeId,
      'timestamp': _timestamp,
    });

    final targetNode = communicationManager.peers
        .firstWhere((peer) => peer.address.contains(targetNodeId.toString()));
    if (targetNode.isConnected) {
      targetNode.sendMessage(reply);
    }
  }

  bool _allRepliesReceived() =>
      _replies.length ==
      communicationManager.peers.where((p) => p.isConnected).length;

  void _accessResource() {
    _state = MutexState.held;
    //TODO invia ordine
    _releaseResource();
  }

  void _releaseResource() {
    _state = MutexState.released;
    _replies = [];
  }
}
