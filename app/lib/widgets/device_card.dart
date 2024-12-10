import 'package:fuori_nevica/models/node.dart';
import 'package:flutter/material.dart';

class DeviceCard extends StatelessWidget {
  final Node device;

  const DeviceCard({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.circle,
          color: device.isConnected ? Colors.green : Colors.red,
        ),
        title: Text('${device.name} (ID: ${device.id})'),
        subtitle: Text(device.address),
        trailing: const Icon(Icons.smartphone),
      ),
    );
  }
}
