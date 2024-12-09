import 'package:flutter/material.dart';
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
    final order = orderProvider.order;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [],
        ),
      ),
    );
  }
}
