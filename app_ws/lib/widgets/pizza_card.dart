import 'package:app_ws/viewmodels/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PizzaCard extends StatelessWidget {
  final String pizza;

  const PizzaCard({required this.pizza});

  @override
  Widget build(BuildContext context) {
    final pizzaOrderModel = Provider.of<OrderProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        title: Row(
          children: [
            Expanded(
              child: Text(pizza, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueAccent),
              iconSize: 30,
              onPressed: () {
                _showEditIngredientsDialog(context, pizzaOrderModel, pizza);
              },
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove, color: Colors.redAccent),
              iconSize: 30,
              onPressed: () {
                pizzaOrderModel.removeFromOrder(pizza);
              },
            ),
            Text('${pizzaOrderModel.getPizzaCount(pizza)}', style: const TextStyle(fontSize: 24)),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.green),
              iconSize: 30,
              onPressed: () {
                pizzaOrderModel.addToOrder(pizza);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditIngredientsDialog(BuildContext context, OrderProvider pizzaOrderModel, String pizza) {
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
}