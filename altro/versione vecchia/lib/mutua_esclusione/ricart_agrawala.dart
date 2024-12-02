import 'package:grpc/grpc.dart';
import 'ricart_agrawala.pbgrpc.dart';
import 'dart:async';
import 'dart:math';

class RicartAgrawalaClient {
  ClientChannel channel;
  RicartAgrawalaClientStub stub;

  RicartAgrawalaClient(String address, int port) {
    channel = ClientChannel(
      address,
      port: port,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    stub = RicartAgrawalaClientStub(channel);
  }

  Future<Response> requestAccess(String nodeId, int timestamp) async {
    final request = Request()
      ..node_id = nodeId
      ..timestamp = timestamp;
    return await stub.requestAccess(request);
  }

  Future<Response> releaseAccess(String nodeId, int timestamp) async {
    final request = Request()
      ..node_id = nodeId
      ..timestamp = timestamp;
    return await stub.releaseAccess(request);
  }

  Future<void> shutdown() async {
    await channel.shutdown();
  }
}

class RicartAgrawalaServer extends RicartAgrawalaServiceBase {
  final String nodeId;
  int timestamp = 0;
  bool requesting = false;
  bool inCriticalSection = false;
  final List<Request> requestQueue = [];
  final List<RicartAgrawalaClient> clients;

  RicartAgrawalaServer(this.nodeId, this.clients);

  @override
  Future<Response> requestAccess(ServiceCall call, Request request) async {
    timestamp = max(timestamp, request.timestamp) + 1;
    if (inCriticalSection || (requesting && (timestamp < request.timestamp || (timestamp == request.timestamp && nodeId.compareTo(request.node_id) < 0)))) {
      requestQueue.add(request);
      return Response()..granted = false;
    } else {
      return Response()..granted = true;
    }
  }

  @override
  Future<Response> releaseAccess(ServiceCall call, Request request) async {
    timestamp = max(timestamp, request.timestamp) + 1;
    if (requestQueue.isNotEmpty) {
      final nextRequest = requestQueue.removeAt(0);
      // Invia una risposta positiva al prossimo nodo nella coda
      final client = clients.firstWhere((client) => client.stub.channel.host == nextRequest.node_id);
      await client.requestAccess(nextRequest.node_id, nextRequest.timestamp);
    }
    return Response()..granted = true;
  }

  Future<void> enterCriticalSection() async {
    requesting = true;
    timestamp++;
    // Invia richieste di accesso a tutti gli altri nodi
    for (final client in clients) {
      await client.requestAccess(nodeId, timestamp);
    }
    requesting = false;
    inCriticalSection = true;
  }

  void exitCriticalSection() {
    inCriticalSection = false;
    // Invia risposte di rilascio a tutti i nodi in attesa
    for (final request in requestQueue) {
      final client = clients.firstWhere((client) => client.stub.channel.host == request.node_id);
      client.releaseAccess(request.node_id, request.timestamp);
    }
    requestQueue.clear();
  }
}

Future<void> main(List<String> args) async {
  final clients = [
    RicartAgrawalaClient('node2_address', 50051),
    RicartAgrawalaClient('node3_address', 50051),
    // Aggiungi altri client per ogni nodo nel sistema
  ];

  final server = Server([RicartAgrawalaServer('node1', clients)]);
  await server.serve(port: 50051);
  print('Server listening on port ${server.port}...');
}
