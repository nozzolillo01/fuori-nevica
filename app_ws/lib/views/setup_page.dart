import 'package:fuori_nevica/config.dart';
import 'package:fuori_nevica/mutex/communication_manager.dart';
import 'package:fuori_nevica/mutex/node.dart';
import 'package:fuori_nevica/viewmodels/setup_provider.dart';
import 'package:fuori_nevica/widgets/device_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SetupPage extends StatefulWidget {
  @override
  _SetupPageState createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  CommunicationManager communicationManager = CommunicationManager();
  List<Node> knownPeers = [];

  @override
  void initState() {
    super.initState();
    _refreshPeers();
  }

  Future<void> _refreshPeers() async {
    setState(() {
      knownPeers = communicationManager.peers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SetupProvider>(
      builder: (context, setupProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Configurazione'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(communicationManager.nodeName),
                FutureBuilder<String>(
                  future: Shared.getIpAddress(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return const Text('-');
                    } else {
                      return Text('${snapshot.data}');
                    }
                  },
                ),
                ElevatedButton(
                  onPressed: _refreshPeers,
                  child: const Text('AGGIORNA'),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: knownPeers.isNotEmpty
                      ? ListView.builder(
                          itemCount: knownPeers.length,
                          itemBuilder: (context, index) {
                            final peer = knownPeers[index];
                            return DeviceCard(device: peer);
                          },
                        )
                      : const Center(
                          child: Text('Nessun altro cameriere registrato')),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
