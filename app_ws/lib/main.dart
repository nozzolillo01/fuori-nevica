import 'package:fuori_nevica/viewmodels/setup_provider.dart';
import 'package:fuori_nevica/views/loading_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import 'viewmodels/order_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChannels.lifecycle.setMessageHandler((message) async {
    if (message == 'AppLifecycleState.paused') {
      debugPrint("App in background");
    } else if (message == 'AppLifecycleState.detached') {
      debugPrint("App chiusa");
      //TODO close server
    }

    return null;
  });

  runApp(const App());
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
