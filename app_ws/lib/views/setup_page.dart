import 'package:app_ws/config.dart';
import 'package:app_ws/services/webservice.dart';
import 'package:app_ws/viewmodels/setup_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SetupPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Consumer<SetupProvider>(
      builder: (context, setupProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Configurazione'),
            leading: 
              IconButton(
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
                Text('${setupProvider.mutex?.nodeName}'),
                FutureBuilder<String>(
                  future: Config.getIpAddress(),
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
                  onPressed: () async {
                    setupProvider.refreshNodes();
                  },
                  child: const Text('RESET CONNESSIONE'),
                ),
                const SizedBox(height: 16),
                const Text('Stato Connessione Peer:'),
                Expanded(
                  child: setupProvider.mutex?.getConnectedPeers().isNotEmpty ?? false
                      ? ListView.builder(
                          itemCount: setupProvider.mutex!.getConnectedPeers().length,
                          itemBuilder: (context, index) {
                            final peer = setupProvider.mutex?.getConnectedPeers().elementAt(index);
                            return ListTile(
                              title: Text('${peer?.name} (${peer?.address})'),
                              subtitle: Text(peer != null && peer.isConnected ? 'Connesso' : 'Disconnesso'),
                            );
                          },
                        )
                      : const Center(child: Text('Nessun altro cameriere registrato')),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
