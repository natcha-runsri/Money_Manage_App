import 'package:flutter/material.dart';

class BillDetailPage extends StatelessWidget {

  final Map<String, dynamic> bill;

  const BillDetailPage({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Bill Detail"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              bill["bill_name"],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height:20),

            Text("Amount : ${bill["amount"]} ฿"),

            const SizedBox(height:10),

            Text("Status : ${bill["status"]}"),

            const SizedBox(height:10),

            Text("Note : ${bill["note"] ?? "-"}"),

          ],
        ),
      ),
    );
  }
}