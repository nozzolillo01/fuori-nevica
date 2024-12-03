import 'package:app_ws/mutex/communication_manager.dart';
import 'package:flutter/material.dart';

class SetupProvider with ChangeNotifier {
  CommunicationManager? _mutex;
  List<dynamic> _ingredienti = [];

  CommunicationManager? get mutex => _mutex;
  List<dynamic> get ingredienti => _ingredienti;

  void refreshNodes() {
    _mutex?.refreshNodes();
    notifyListeners();
  }

  void setMutex(CommunicationManager mutex) {
    _mutex = mutex;
    notifyListeners();
  }

  void setIngredienti(List<dynamic> ingredienti) {
    _ingredienti = ingredienti;
    notifyListeners();
  }
}
