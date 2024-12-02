import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => PizzaOrderModel(),
      child: const MyApp(),
    ),
  );
}

class PizzaOrderModel extends ChangeNotifier {
  final List<String> _availablePizzas = [
    'Margherita', 'Marinara', 'Capricciosa', 'Provola e Pepe', 'Diavola', 
    'Quattro Stagioni', 'Quattro Formaggi', 'Napoletana', 'Focaccia', 
    'Siciliana', 'Bufalina', 'Ortolana'
  ];

  final Map<String, List<String>> _pizzaIngredients = {
    'Margherita': ['Tomato', 'Mozzarella', 'Basil'],
    'Marinara': ['Tomato', 'Garlic', 'Oregano'],
    'Capricciosa': ['Tomato', 'Mozzarella', 'Ham', 'Artichokes', 'Mushrooms', 'Olives'],
    'Provola e Pepe': ['Provola', 'Pepper'],
    'Diavola': ['Tomato', 'Mozzarella', 'Spicy Salami'],
    'Quattro Stagioni': ['Tomato', 'Mozzarella', 'Ham', 'Artichokes', 'Mushrooms', 'Olives'],
    'Quattro Formaggi': ['Mozzarella', 'Gorgonzola', 'Parmesan', 'Fontina'],
    'Napoletana': ['Tomato', 'Mozzarella', 'Anchovies', 'Capers'],
    'Focaccia': ['Olive Oil', 'Rosemary'],
    'Siciliana': ['Tomato', 'Mozzarella', 'Eggplant', 'Ricotta'],
    'Bufalina': ['Tomato', 'Buffalo Mozzarella', 'Basil'],
    'Ortolana': ['Tomato', 'Mozzarella', 'Grilled Vegetables'],
  };

  final Map<String, int> _order = {};

  List<String> get availablePizzas => _availablePizzas;
  Map<String, int> get order => _order;

  List<String> getPizzaIngredients(String pizza) => _pizzaIngredients[pizza] ?? [];

  void addToOrder(String pizza) {
    _order[pizza] = (_order[pizza] ?? 0) + 1;
    notifyListeners();
  }

  void removeFromOrder(String pizza) {
    if (_order.containsKey(pizza) && _order[pizza]! > 0) {
      _order[pizza] = _order[pizza]! - 1;
      if (_order[pizza] == 0) _order.remove(pizza);
    }
    notifyListeners();
  }

  int getPizzaCount(String pizza) => _order[pizza] ?? 0;

  void placeOrder() {
    // Send order to the server if the pizza can be prepared 
    _order.clear();
    notifyListeners();
  }

  void resetOrder() {
    _order.clear();
    notifyListeners();
  }

  void addCustomPizza(String pizza, List<String> ingredients) {
    final customPizza = '$pizza (${ingredients.join(', ')})';
    addToOrder(customPizza);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pizza Order App',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey[200],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.redAccent,
          titleTextStyle: TextStyle(
            color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.redAccent,
        ),
      ),
      home: const MyHomePage(title: 'Pizza Order Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final pizzaOrderModel = Provider.of<PizzaOrderModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
                  OrderButton(
                    label: 'Place Order',
                    icon: Icons.check,
                    color: Colors.green,
                    onPressed: () => _showConfirmationDialog(context, pizzaOrderModel),
                  ),
                  const SizedBox(width: 16),
                  OrderButton(
                    label: 'Reset',
                    icon: Icons.close,
                    color: Colors.red,
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

  void _showEditIngredientsDialog(BuildContext context, PizzaOrderModel pizzaOrderModel, String pizza) {
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

  void _showConfirmationDialog(BuildContext context, PizzaOrderModel pizzaOrderModel) {
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
                _showSnackBar(context, 'Order placed successfully!', Colors.green);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _showResetDialog(BuildContext context, PizzaOrderModel pizzaOrderModel) {
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

class PizzaCard extends StatelessWidget {
  final String pizza;

  const PizzaCard({super.key, required this.pizza});

  @override
  Widget build(BuildContext context) {
    final pizzaOrderModel = Provider.of<PizzaOrderModel>(context, listen: false);

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

  void _showEditIngredientsDialog(BuildContext context, PizzaOrderModel pizzaOrderModel, String pizza) {
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

class OrderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const OrderButton({super.key, 
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      label: Text(
        label,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
      icon: Icon(icon, color: Colors.white),
      backgroundColor: color,
    );
  }
}

