import 'package:flutter/material.dart';
import 'package:fuori_nevica/services/webservice.dart';
import 'package:fuori_nevica/config.dart';
import 'package:fuori_nevica/services/communication_manager.dart';
import 'package:fuori_nevica/views/order_page.dart';
import 'package:fuori_nevica/widgets/loading_indicator.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final WebService webService = WebService();
  final CommunicationManager communicationManager = CommunicationManager();
  String statusMessage = "Inizializzazione...";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    try {
      setMessage("Recupero il mio indirizzo ip...");
      final myIp = await Shared.getIpAddress();

      setMessage("Download degli altri nodi...");
      await Future.delayed(const Duration(seconds: 3));
      final knownPeers = await webService.getCamerieri();
      final myself = knownPeers.where((peer) => peer['indirizzo'] == myIp);

      int myId = -1;
      String myName = '';
      if (myself.isEmpty) {
        setMessage("Nuovo device, registrazione in corso...");

        myName = await _inputDeviceName();
        myId = await webService.register(myIp, myName);
      } else {
        setMessage("Recupero il mio id...");
        myId = myself.first['id'];
        myName = myself.first['nome'];
      }

      setMessage("Inizializzazione del Mutex...");
      await Future.delayed(const Duration(seconds: 2));
      communicationManager.nodeId = myId;
      communicationManager.nodeName = myName;
      for (var peer in knownPeers) {
        if (peer['indirizzo'] == myIp) continue;

        communicationManager.addNode(peer['id'], peer['indirizzo'],
            name: peer['nome']);
      }

      setMessage("Notifico la mia presenza...");
      await Future.delayed(const Duration(seconds: 1));
      communicationManager.notifyJoin();

      setMessage("Caricamento completato. Avvio...");
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const OrderPage(),
        ),
      );
    } catch (e) {
      setMessage("Errore durante l'inizializzazione dell'app: ${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void setMessage(String message) {
    setState(() {
      statusMessage = message;
    });
  }

  Future<String> _inputDeviceName() async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: const Text('Assegna un nome al dispositivo'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Nome dispositivo"),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
            ),
          ],
        );
      },
    );
    return result ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Caricamento...')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //const CircularProgressIndicator(),
            const WiFiAnimation(
              size: 200,
            ),
            //const SizedBox(height: 20),
            Text(
              statusMessage,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
