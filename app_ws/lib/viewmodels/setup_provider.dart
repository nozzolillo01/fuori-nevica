import 'package:app_ws/mutex/ricart_agrawala.dart';
import 'package:flutter/material.dart';

class SetupProvider with ChangeNotifier {
  DistributedMutex? _mutex;
  List<dynamic> _ingredienti = [];

  DistributedMutex? get mutex => _mutex;
  List<dynamic> get ingredienti => _ingredienti;

  void refreshNodes() {
    _mutex?.refreshNodes();
    notifyListeners();
  }

  void setMutex(DistributedMutex mutex) {
    _mutex = mutex;
    notifyListeners();
  }

  void setIngredienti(List<dynamic> ingredienti) {
    _ingredienti = ingredienti;
    notifyListeners();
  }

}
