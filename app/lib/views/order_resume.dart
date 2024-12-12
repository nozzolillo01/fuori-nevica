import 'package:flutter/material.dart';
import 'package:fuori_nevica/models/pizza.dart';
import 'package:fuori_nevica/viewmodels/order_provider.dart';
import 'package:provider/provider.dart';

class ResumeOrderPage extends StatefulWidget {
  const ResumeOrderPage({super.key});

  @override
  _ResumeOrderState createState() => _ResumeOrderState();
}

class _ResumeOrderState extends State<ResumeOrderPage> {
  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final order = orderProvider.order as Map<Pizza, int>;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: order.isEmpty
                  ? const Text(
                      "Aggiungi pizze all'ordine per visualizzarne il riepilogo",
                      textAlign: TextAlign.center,
                    )
                  : ListView.builder(
                      itemCount: order.length,
                      itemBuilder: (context, index) {
                        final pizza = order.keys.elementAt(index);
                        final quantity = order[pizza]!;
                        return Card(
                          color: Colors.white,
                          child: ListTile(
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.remove,
                                color: Colors.redAccent,
                                weight: 5,
                              ),
                              onPressed: () {
                                orderProvider.removeFromOrder(pizza);
                              },
                            ),
                            title: Text(
                              pizza.nome,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            leading: Text('x$quantity',
                                style: const TextStyle(fontSize: 20)),
                          ),
                        );
                      },
                    ),
            ),
            const Divider(thickness: 2),
            Text(
              'TOTALE:  ${order.values.fold(0, (sum, quantity) => sum + quantity)} pizze',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
