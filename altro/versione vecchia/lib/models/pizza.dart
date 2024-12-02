/*class Pizza {
  String name;
  List<String> ingredienti;

  Pizza(this.name, this.ingredienti);
}*/

import 'package:flutter/material.dart';

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
