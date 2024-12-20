import 'package:fuori_nevica/models/pizza.dart';
import 'package:fuori_nevica/viewmodels/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PizzaCard extends StatelessWidget {
  final Pizza pizza;

  const PizzaCard({super.key, required this.pizza});

  @override
  Widget build(BuildContext context) {
    final pizzaOrderModel = Provider.of<OrderProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Colors.white,
      elevation: 5,
      child: ListTile(
        leading: Image.asset('assets/pizza-icon.png', width: 48),
        contentPadding: const EdgeInsets.all(10),
        title: Row(
          children: [
            Expanded(
              child: Text(pizza.nome,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            /*IconButton(
              icon: const Icon(Icons.remove, color: Colors.redAccent),
              iconSize: 30,
              onPressed: () {
                pizzaOrderModel.removeFromOrder(pizza);
              },
            ),
            Text('${pizzaOrderModel.getPizzaCount(pizza)}',
                style: const TextStyle(fontSize: 24)),*/
            IconButton(
              icon: const Icon(Icons.edit),
              iconSize: 30,
              onPressed: () {
                _showEditIngredientsDialog(context, pizzaOrderModel, pizza);
              },
            ),
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

  void _showEditIngredientsDialog(
      BuildContext context, OrderProvider pizzaOrderModel, Pizza pizza) {
    final ingredients = pizza.ingredienti;
    final selectedIngredients = List<String>.from(ingredients);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('MODIFICA INGREDIENTI DI ${pizza.nome}'),
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
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () {
                pizzaOrderModel.addCustomPizza(pizza, selectedIngredients);
                Navigator.of(context).pop();
              },
              child: const Text('Aggiungi'),
            ),
          ],
        );
      },
    );
  }
}
