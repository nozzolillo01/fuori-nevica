import 'package:fuori_nevica/mutex/communication_manager.dart';
import 'package:flutter/material.dart';

class SetupProvider with ChangeNotifier {
  CommunicationManager communicationManager = CommunicationManager();

  List<dynamic> _ingredienti = [];
  List<dynamic> get ingredienti => _ingredienti;

  void refreshNodes() {
    //TODO reload
    notifyListeners();
  }

  void setIngredienti(List<dynamic> ingredienti) {
    _ingredienti = ingredienti;
    notifyListeners();
  }
}
