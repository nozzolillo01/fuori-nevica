import 'package:fuori_nevica/models/pizza.dart';
import 'package:fuori_nevica/viewmodels/order_provider.dart';
import 'package:fuori_nevica/views/setup_page.dart';
import 'package:fuori_nevica/widgets/pizza_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  @override
  Widget build(BuildContext context) {
    final pizzaOrderModel = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FUORI NEVICA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SetupPage()),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: ListView.builder(
              itemCount: pizzaOrderModel.availablePizzas.length,
              itemBuilder: (context, index) {
                final pizza = pizzaOrderModel.availablePizzas[index];
                return PizzaCard(pizza: pizza);
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () =>
                        _showConfirmationDialog(context, pizzaOrderModel),
                    child: const Row(
                      children: [
                        Text('CONFERMA'),
                        Icon(Icons.check),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    child: const Row(
                      children: [
                        Text('AZZERA'),
                        Icon(Icons.clear),
                      ],
                    ),
                    onPressed: () => _showResetDialog(context, pizzaOrderModel),
                  ),
                ],
              ),
            ),
          ),
        ],
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
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                pizzaOrderModel.placeOrder();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.green,
                    content: Text("Ordine inviato!"),
                  ),
                );
              },
              child: const Text('CONFERMA'),
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
          title: const Text('Reset Order'),
          content: const Text('Are you sure you want to RESET the order?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
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
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
