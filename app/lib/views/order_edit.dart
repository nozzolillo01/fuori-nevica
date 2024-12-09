import 'package:fuori_nevica/viewmodels/order_provider.dart';
import 'package:fuori_nevica/widgets/pizza_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditOrderPage extends StatefulWidget {
  const EditOrderPage({super.key});

  @override
  State<EditOrderPage> createState() => _EditOrderPageState();
}

class _EditOrderPageState extends State<EditOrderPage> {
  @override
  Widget build(BuildContext context) {
    final pizzaOrderModel = Provider.of<OrderProvider>(context);

    return Scaffold(
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
        ],
      ),
    );
  }
}
