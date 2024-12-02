import 'package:flutter/material.dart';

class OrderProvider extends ChangeNotifier {
  final List<String> _availablePizzas = [
    'Margherita', 'Marinara', 'Capricciosa', 'Provola e Pepe', 'Diavola', 
    'Quattro Stagioni', 'Quattro Formaggi', 'Napoletana', 'Focaccia', 
    'Siciliana', 'Bufalina', 'Ortolana'
  ];

  final Map<String, List<String>> _pizzaIngredients = {
    'Margherita': ['Pomodoro', 'Mozzarella', 'Basilico'],
    'Marinara': ['Pomodoro', 'Aglio', 'Origano'],
    'Capricciosa': ['Pomodoro', 'Mozzarella', 'Prosciutto', 'Carciofi', 'Funghi', 'Olive'],
    'Provola e Pepe': ['Pomodoro', 'Provola', 'Pepe'],
    'Diavola': ['Pomodoro', 'Mozzarella', 'Salame Piccante'],
    'Quattro Stagioni': ['Pomodoro', 'Mozzarella', 'Prosciutto', 'Carciofi', 'Funghi', 'Olive'],
    'Quattro Formaggi': ['Mozzarella', 'Gorgonzola', 'Parmigiano', 'Fontina'],
    'Napoletana': ['Pomodoro', 'Mozzarella', 'Acciughe', 'Capperi'],
    'Focaccia': ['Olio d\'Oliva', 'Rosmarino'],
    'Siciliana': ['Pomodoro', 'Mozzarella', 'Melanzane', 'Ricotta'],
    'Bufalina': ['Pomodoro', 'Mozzarella di Bufala', 'Basilico'],
    'Ortolana': ['Pomodoro', 'Mozzarella', 'Verdure Grigliate'],
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
    //TODO get consenso
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
