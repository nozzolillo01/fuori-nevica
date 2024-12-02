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