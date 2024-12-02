import 'package:app_ws/views/order_page.dart';
import 'package:flutter/material.dart';
import 'package:app_ws/services/webservice.dart';
import 'package:app_ws/config.dart';
import 'package:app_ws/viewmodels/setup_provider.dart';
import 'package:provider/provider.dart';
import 'package:app_ws/mutex/ricart_agrawala.dart'; 

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final WebService webService = WebService();
  String statusMessage = "Inizializzazione...";

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      setMessage("Recupero il mio indirizzo ip...");
      final myIp = await Config.getIpAddress();

      setMessage("Download degli altri nodi...");
      final knownPeers = await webService.getCamerieri();
      final myself = knownPeers.where((peer) => peer['indirizzo'] == myIp);

      int myId = -1;
      String myName = '';
      bool newDevice = false;
      if(myself.isEmpty) {
        setMessage("Registrazione come cameriere...");
        
        String name = await _inputDeviceName();
        myId = await webService.register(myIp, name.isEmpty ? myIp : name);
        myName = name;
        newDevice = true;
      } else {
        setMessage("Recupero il mio id...");
        myId = myself.first['id'];
        myName = myself.first['nome'];
      }

      setMessage("Inizializzazione del Mutex...");
      final mutex = DistributedMutex(myId, myName, knownPeers.where((peer) => peer['indirizzo'] != myIp).toList());

      if(newDevice) {
        setMessage("Comunico la mia registrazione...");
        debugPrint("/**************************************** Notifying registration");
        mutex.notifyRegistration();
      }

      setMessage("Download degli ingredienti...");
      final ingredienti = await webService.getIngredienti();

      final setupProvider = Provider.of<SetupProvider>(context, listen: false);
      setupProvider.setMutex(mutex);
      setupProvider.setIngredienti(ingredienti);

      setMessage("Caricamento completato. Avvio...");

      _navigateToOrderPage();
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

  void _navigateToOrderPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const OrderPage(),
      ),
    );
  }

  Future<String> _inputDeviceName() async {
    final result = await showDialog(
          context: context,
          builder: (BuildContext context) {
            TextEditingController controller = TextEditingController();
            return AlertDialog(
              title: Text('Inserisci il nome del dispositivo'),
              content: TextField(
                controller: controller,
                decoration: InputDecoration(hintText: "Nome dispositivo"),
              ),
              actions: [
                TextButton(
                  child: Text('OK'),
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
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
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
