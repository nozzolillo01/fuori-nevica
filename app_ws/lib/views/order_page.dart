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
              MaterialPageRoute(builder: (context) => SetupPage()),
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
                        Text('Place Order'),
                        Icon(Icons.check),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    child: const Row(
                      children: [
                        Text('Reset Order'),
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

  void _showEditIngredientsDialog(
      BuildContext context, OrderProvider pizzaOrderModel, String pizza) {
    final ingredients = pizzaOrderModel.getPizzaIngredients(pizza);
    final selectedIngredients = List<String>.from(ingredients);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Ingredients for $pizza'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: ingredients.map((ingredient) {
                  return CheckboxListTile(
                    title: Text(ingredient),
                    value: selectedIngredients.contains(ingredient),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedIngredients.add(ingredient);
                        } else {
                          selectedIngredients.remove(ingredient);
                        }
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                pizzaOrderModel.addCustomPizza(pizza, selectedIngredients);
                pizzaOrderModel.addToOrder(pizza);
                Navigator.of(context).pop();
              },
              child: const Text('Add to Order'),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog(
      BuildContext context, OrderProvider pizzaOrderModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Order'),
          content: const Text('Are you sure you want to PLACE the order?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                pizzaOrderModel.placeOrder();
                Navigator.of(context).pop();
                _showSnackBar(
                    context, 'Order placed successfully!', Colors.green);
              },
              child: const Text('Confirm'),
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
                _showSnackBar(context, 'Order reset successfully!', Colors.red);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 24),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(32.0),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
