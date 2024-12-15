import 'package:fuori_nevica/services/communication_manager.dart';
import 'package:fuori_nevica/views/init_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import 'viewmodels/order_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChannels.lifecycle.setMessageHandler((message) async {
    if (message == 'AppLifecycleState.detached') {
      CommunicationManager().reset(); //TODO Check
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
        ChangeNotifierProvider(create: (context) => OrderProvider()),
      ],
      child: MaterialApp(
        home: const InitPage(),
        theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            color: Colors.red,
            titleTextStyle: TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            iconTheme: IconThemeData(color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}
