import 'package:flutter/material.dart';
import 'package:fuori_nevica/viewmodels/order_provider.dart';
import 'package:fuori_nevica/views/order_edit.dart';
import 'package:fuori_nevica/views/order_resume.dart';
import 'package:fuori_nevica/views/setup_page.dart';
import 'package:fuori_nevica/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  OrderPageState createState() => OrderPageState();
}

class OrderPageState extends State<OrderPage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const EditOrderPage(),
    const ResumeOrderPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        centerTitle: true,
        leading: Image.asset('assets/logo-icon.png', height: 40),
        title: const Text(
          'E Fuori Nevica',
          style: TextStyle(
              fontFamily: 'DancingScript',
              fontWeight: FontWeight.bold,
              fontSize: 32),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phonelink_ring),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SetupPage()),
            ),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 5.0),
              child: FloatingActionButton.extended(
                backgroundColor: Colors.green,
                onPressed: () =>
                    _showConfirmationDialog(context, orderProvider),
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text(
                  'CONFERMA',
                  style: TextStyle(color: Colors.white),
                ),
                heroTag: 'confirm',
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0, left: 5.0),
              child: FloatingActionButton.extended(
                backgroundColor: Colors.grey,
                onPressed: () => _showResetDialog(context, orderProvider),
                icon: const Icon(Icons.cancel, color: Colors.white),
                label: const Text(
                  'AZZERA',
                  style: TextStyle(color: Colors.white),
                ),
                heroTag: 'reset',
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.white,
        backgroundColor: Colors.red,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.create),
            label: 'Ordine',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Riepilogo',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _showConfirmationDialog(
      BuildContext context, OrderProvider pizzaOrderModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('CONFERMA'),
          content: const Text('SEI SICURO DI VOLER CONFERMARE L\'ORDINE?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ANNULLA'),
            ),
            TextButton(
              onPressed: () async {
                _showLoadingDialog(context, pizzaOrderModel);
                final errors = await pizzaOrderModel.placeOrder();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                if (errors.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.green,
                      content: Text("Ordine inviato!"),
                    ),
                  );
                } else {
                  _showErrorDialog(context, pizzaOrderModel, errors);
                }
              },
              child: const Text('CONFERMA'),
            ),
          ],
        );
      },
    );
  }

  void _showLoadingDialog(BuildContext context, OrderProvider pizzaOrderModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('INVIO ORDINE'),
          content: WiFiAnimation(size: 200),
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, OrderProvider pizzaOrderModel,
      Map<String, dynamic> errors) {
    //TODO grafica
    final errorString = errors.entries
        .map((entry) =>
            'x1 ${entry.key.toUpperCase().split("_")[0]}:\n${entry.value.join(', ')}\n')
        .join('\n');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ATTENZIONE!'),
          content: Text('L\'ORDINE NON PUÒ ESSERE REALIZZATO:\n$errorString'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showResetDialog(BuildContext context, OrderProvider pizzaOrderModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('RESET ORDINE'),
          content: const Text('SEI SICURO DI VOLER AZZERARE L\'ORDINE?'),
          actions: <Widget>[
            TextButton(
              child: const Text('ANNULLA'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('CONFERMA'),
              onPressed: () {
                pizzaOrderModel.resetOrder();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.red,
                    content: Text("Ordine azzerato!"),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
