import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {

    final uid = FirebaseAuth.instance.currentUser!.uid;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            const Text(
              "Dashboard",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            /// SUMMARY
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("user")
                  .doc(uid)
                  .collection("transactions")
                  .snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const SizedBox();
                }

                double income = 0;
                double expense = 0;

                for (var doc in snapshot.data!.docs) {

                  final data = doc.data() as Map<String, dynamic>;

                  double amount = (data["amount"] as num).toDouble();

                  if (data["type"] == "income") {
                    income += amount;
                  } else {
                    expense += amount;
                  }
                }

                double balance = income - expense;

                return Column(
                  children: [

                    _summaryCard(
                        "Income",
                        income,
                        Colors.green
                    ),

                    const SizedBox(height:10),

                    _summaryCard(
                        "Expense",
                        expense,
                        Colors.red
                    ),

                    const SizedBox(height:10),

                    _summaryCard(
                        "Balance",
                        balance,
                        Colors.blueGrey
                    ),

                  ],
                );
              },
            ),

            const SizedBox(height:20),

            /// BUDGET SUMMARY
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Budget Summary",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height:10),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const LinearProgressIndicator(
                      value: 0.92,
                      minHeight: 10,
                      color: Colors.purple,
                    ),
                  ),

                  const SizedBox(height:6),

                  const Text(
                    "เตือนเมื่อใกล้เกิน Budget",
                    style: TextStyle(color: Colors.red),
                  )

                ],
              ),
            ),

            const SizedBox(height:20),

            /// PIE CHART
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Expense Overview",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height:20),

                  SizedBox(
                    height:200,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                              value: 35,
                              color: Colors.green,
                              title: "Food"),
                          PieChartSectionData(
                              value: 20,
                              color: Colors.purple,
                              title: "Shopping"),
                          PieChartSectionData(
                              value: 20,
                              color: Colors.blue,
                              title: "Bills"),
                          PieChartSectionData(
                              value: 15,
                              color: Colors.orange,
                              title: "Transport"),
                          PieChartSectionData(
                              value: 10,
                              color: Colors.grey,
                              title: "Other"),
                        ],
                      ),
                    ),
                  )

                ],
              ),
            )

          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String title,double value,Color color){

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold
              )
          ),

          Text("฿ ${value.toStringAsFixed(0)}")

        ],
      ),
    );

  }
}