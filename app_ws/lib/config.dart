import 'dart:io';

class Config {
  static const int websocketPort = 8080;
  static const String apiBaseUrl = 'http://192.168.241.1:5000';

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
