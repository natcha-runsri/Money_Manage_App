import 'package:flutter/material.dart';

class BillPage extends StatelessWidget {
  const BillPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Account"),
      ),
      body: const Center(
        child: Text("Account details will be shown here."),
      ),
    );    

  }
}