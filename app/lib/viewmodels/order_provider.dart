import 'package:flutter/material.dart';
import 'package:fuori_nevica/models/pizza.dart';
import 'package:fuori_nevica/mutex/ricart_agrawala.dart';
import 'package:fuori_nevica/services/webservice.dart';

class OrderProvider extends ChangeNotifier {
  final List<Pizza> _availablePizzas = [
    Pizza('Margherita', ['Pomodoro', 'Mozzarella', 'Basilico']),
    Pizza('Marinara', ['Pomodoro', 'Aglio', 'Origano']),
    Pizza('Capricciosa', [
      'Pomodoro',
      'Mozzarella',
      'Prosciutto',
      'Carciofi',
      'Funghi',
      'Olive'
    ]),
    Pizza('Provola e Pepe', ['Pomodoro', 'Provola', 'Pepe']),
    Pizza('Diavola', ['Pomodoro', 'Mozzarella', 'Salame Piccante']),
    Pizza('Quattro Stagioni', [
      'Pomodoro',
      'Mozzarella',
      'Prosciutto',
      'Carciofi',
      'Funghi',
      'Olive'
    ]),
    Pizza('Quattro Formaggi',
        ['Mozzarella', 'Gorgonzola', 'Parmigiano', 'Fontina']),
    Pizza('Napoletana', ['Pomodoro', 'Mozzarella', 'Acciughe', 'Capperi']),
    Pizza('Focaccia', ['Olio d\'Oliva', 'Rosmarino']),
    Pizza('Siciliana', ['Pomodoro', 'Mozzarella', 'Melanzane', 'Ricotta']),
    Pizza('Bufalina', ['Pomodoro', 'Mozzarella di Bufala', 'Basilico']),
    Pizza('Ortolana', ['Pomodoro', 'Mozzarella', 'Verdure Grigliate']),
  ];

  final Map<Pizza, int> _order = {};

  List<Pizza> get availablePizzas => _availablePizzas;
  Map<Pizza, int> get order => _order;

  void addToOrder(Pizza pizza) {
    _order[pizza] = (_order[pizza] ?? 0) + 1;
    notifyListeners();
  }

  void removeFromOrder(Pizza pizza) {
    if (_order.containsKey(pizza) && _order[pizza]! > 0) {
      _order[pizza] = _order[pizza]! - 1;
      if (_order[pizza] == 0) _order.remove(pizza);
    }
    notifyListeners();
  }

  int getPizzaCount(Pizza pizza) => _order[pizza] ?? 0;

  Future<Map<String, dynamic>> placeOrder() async {
    final mutex = RicartAgrawala();

    await mutex.requestResource(); //LOCK

    await Future.delayed(const Duration(seconds: 5));
    final errors = processOrder();

    mutex.releaseResource(); //UNLOCK
    return errors;
  }

  Future<Map<String, dynamic>> processOrder() async {
    Map<String, List<String>> wsOrder = {};
    for (final pizza in _order.keys) {
      for (var i = 0; i < _order[pizza]!; i++) {
        wsOrder['${pizza.nome}_$i'] = pizza.ingredienti;
      }
    }

    var result = await WebService().sendOrder(wsOrder);
    if (result is String && result == 'OK') {
      resetOrder();
      return {};
    }

    return result;

    /* for (final pizza in errors.keys) {
      final error = errors[pizza]!;
      debugPrint('Errori per $pizza:');
      for (final errorDetail in error) {
        debugPrint(errorDetail);
      }
    }*/
  }

  void resetOrder() {
    _order.clear();
    notifyListeners();
  }

  void addCustomPizza(Pizza pizza, List<String> ingredients) {
    final removedIngredients =
        pizza.ingredienti.toSet().difference(ingredients.toSet());
    final customPizzaName =
        '${pizza.nome} SENZA ${removedIngredients.join(', ')}';
    addToOrder(Pizza(customPizzaName, ingredients));
  }
}
