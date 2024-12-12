import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fuori_nevica/services/communication_manager.dart';
import 'package:fuori_nevica/mutex/mutex_state.dart';

class RicartAgrawala {
  final CommunicationManager communicationManager = CommunicationManager();

  int _currentTimestamp, _requestTimestamp;
  List<int> _replies, _queue;
  MutexState _state;

  static final RicartAgrawala _instance = RicartAgrawala._internal();

  factory RicartAgrawala() {
    return _instance;
  }

  RicartAgrawala._internal()
      : _currentTimestamp = 0,
        _requestTimestamp = 0,
        _replies = [],
        _queue = [],
        _state = MutexState.released;

  Future<void> requestResource() async {
    _state = MutexState.wanted;
    _currentTimestamp++;
    _requestTimestamp = _currentTimestamp;

    final message = jsonEncode({
      'type': 'request',
      'nodeId': communicationManager.nodeId,
      'timestamp': _requestTimestamp,
    });

    communicationManager.multicastMessage(message);
    debugPrint("inviato $message\nATTENDO REPLIES");
    while (!_allRepliesReceived()) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    debugPrint("RICEVUTE TUTTE LE RISPOSTE, ACCEDO RISORSA");
    _accessResource();
  }

  void receiveReply(Map<String, dynamic> data) {
    final otherNodeId = data['nodeId'];
    final otherTimestamp = data['timestamp'] as int;

    _currentTimestamp = max(_currentTimestamp, otherTimestamp) + 1;
    _replies.add(otherNodeId);
  }

  void receiveRequest(Map<String, dynamic> data) {
    final otherNodeId = data['nodeId'];
    final otherTimestamp = data['timestamp'] as int;

    debugPrint(
        'RICEVUTA RICHIESTA <ID: $otherNodeId, TIMESTAMP: $otherTimestamp>');
    _currentTimestamp = max(_currentTimestamp, otherTimestamp) + 1;

    debugPrint(
        'SONO NELLO STATO $_state, MIO TIMESTAMP: $_currentTimestamp, MIO ID: ${communicationManager.nodeId}');
    if (!_shouldQueue(otherTimestamp, otherNodeId)) {
      //REPLY IMMEDIATA
      debugPrint('INVIO REPLY');
      _sendReply(otherNodeId);
    } else {
      debugPrint('ACCODO RICHIESTA');
      _queue.add(otherNodeId);
    }
  }

  bool _shouldQueue(int otherTimestamp, int otherNodeId) {
    return (_state == MutexState.held ||
        (_state == MutexState.wanted &&
            (_requestTimestamp < otherTimestamp ||
                _requestTimestamp == otherTimestamp &&
                    communicationManager.nodeId < otherNodeId)));
  }

  void _sendReply(int targetNodeId) {
    _currentTimestamp++;

    final reply = jsonEncode({
      'type': 'reply',
      'nodeId': communicationManager.nodeId,
      'timestamp': _currentTimestamp,
    });

    final targetNode = communicationManager.peers
        .firstWhere((peer) => peer.id == targetNodeId);
    if (targetNode.isConnected) {
      targetNode.sendMessage(reply);
    }
  }

  bool _allRepliesReceived() =>
      _replies.length ==
      communicationManager.peers.where((p) => p.isConnected).length;

  void _accessResource() async {
    _state = MutexState.held;
    debugPrint('ACCEDO ALLA RISORSA CONDIVISA');
  }

  void releaseResource() {
    _state = MutexState.released;
    _replies = [];

    debugPrint('RILASCIO LA RISORSA, RISPONDO ALLA QUEUE');
    for (final nodeId in _queue) {
      _sendReply(nodeId);
    }

    _queue = [];
  }
}
