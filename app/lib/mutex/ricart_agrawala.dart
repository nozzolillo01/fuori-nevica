import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fuori_nevica/mutex/communication_manager.dart';
import 'package:fuori_nevica/mutex/mutex_state.dart';

class RicartAgrawala {
  final CommunicationManager communicationManager = CommunicationManager();

  int _timestamp;
  List<int> _replies, _queue;
  MutexState _state;

  static final RicartAgrawala _instance = RicartAgrawala._internal();

  factory RicartAgrawala() {
    return _instance;
  }

  RicartAgrawala._internal()
      : _timestamp = 0,
        _replies = [],
        _queue = [],
        _state = MutexState.released;

  Future<void> requestResource() async {
    _state = MutexState.wanted;
    _timestamp++;

    final message = jsonEncode({
      'type': 'request',
      'nodeId': communicationManager.nodeId,
      'timestamp': _timestamp,
    });

    communicationManager.multicastMessage(message);
    debugPrint("inviato $message\nATTENDO REPLIES");
    while (!_allRepliesReceived()) {
      await Future.delayed(Duration(milliseconds: 100));
    }

    debugPrint("RICEVUTE TUTTE LE RISPOSTE, ACCEDO RISORSA");
    _accessResource();
  }

  void receiveReply(Map<String, dynamic> data) {
    final otherNodeId = data['nodeId'];
    final otherTimestamp = data['timestamp'] as int;

    _timestamp = max(_timestamp, otherTimestamp) + 1;
    _replies.add(otherNodeId);
  }

  void receiveRequest(Map<String, dynamic> data) {
    final otherNodeId = data['nodeId'];
    final otherTimestamp = data['timestamp'] as int;

    debugPrint('RICEVUTA RICHIESTA DA $otherNodeId ($otherTimestamp)');
    _timestamp = max(_timestamp, otherTimestamp) + 1;

    if (!_shouldQueue(otherTimestamp, otherNodeId)) {
      //REPLY IMMEDIATA
      debugPrint('INVIO REPLY');
      _sendReply(otherNodeId);
    } else {
      debugPrint('ACCODO RICHIESTA, SONO NELLO STATO $_state');
      _queue.add(otherNodeId);
    }
  }

  bool _shouldQueue(int otherTimestamp, int otherNodeId) {
    //se sono in HELD oppure in WANTED e il timestamp della richiesta è minore del mio
    return (_state == MutexState.held ||
        (_state == MutexState.wanted && _timestamp < otherTimestamp));
  }

  void _sendReply(int targetNodeId) {
    _timestamp++;

    final reply = jsonEncode({
      'type': 'reply',
      'nodeId': communicationManager.nodeId,
      'timestamp': _timestamp,
    });

    debugPrint('INVIO REPLY AL NODO $targetNodeId: $reply');

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
    //TODO invia ordine
    //TODO show communication on ui
    //TODO show logs in setup
    debugPrint('Resource accessed');
    await Future.delayed(Duration(seconds: 20));
    _releaseResource();
  }

  void _releaseResource() {
    _state = MutexState.released;
    _replies = [];

    debugPrint('RILASCIO LA RISORSA, RISPONDO ALLA QUEUE');
    for(final nodeId in _queue) {
      _sendReply(nodeId);
    }

    _queue = [];
  }
}
