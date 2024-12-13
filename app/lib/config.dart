import 'dart:io';

import 'package:fuori_nevica/services/communication_manager.dart';

class Shared {
  static const int websocketPort = 8080;
  static const String apiBaseUrl = 'http://192.168.241.196:5000/api';

  static CommunicationManager? communicationManager;

  static Future<String> getIpAddress() async {
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4) {
          return addr.address;
        }
      }
    }

    return '127.0.0.1';
  }
}
