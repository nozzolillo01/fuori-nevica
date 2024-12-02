import 'package:app_ws/mutex/local_ws.dart';
import 'package:app_ws/viewmodels/setup_provider.dart';
import 'package:app_ws/views/loading_page.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'viewmodels/order_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _startLocalWS();
  
  runApp(const App());
}

Future<void> _startLocalWS() async {
  await LocalWebSocketServer().start();
}

class App extends StatelessWidget {

  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SetupProvider()),
        ChangeNotifierProvider(create: (context) => OrderProvider()),
      ],
      child: const MaterialApp(home: LoadingScreen()),
    );
  }
}