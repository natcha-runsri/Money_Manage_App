import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {

    final uid = FirebaseAuth.instance.currentUser!.uid;

    // 🔥 set status bar color
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xffF6F3F5),
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xffF6F3F5),

      body: SafeArea(
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

              /// 🔥 SUMMARY (REAL DATA)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("user")
                    .doc(uid)
                    .collection("transactions")
                    .snapshots(),
                builder: (context, snapshot) {

                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  double income = 0;
                  double expense = 0;

                  Map<String, double> categoryMap = {};

                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;

                    double amount = (data["amount"] as num).toDouble();
                    String type = data["type"];
                    String category = data["category"] ?? "Other";

                    if (type == "income") {
                      income += amount;
                    } else {
                      expense += amount;

                      // 🔥 group category
                      categoryMap[category] =
                          (categoryMap[category] ?? 0) + amount;
                    }
                  }

                  double balance = income - expense;

                  /// 🔥 convert to pie sections
                  List<PieChartSectionData> sections = [];
                  List<Color> colors = [
                    const Color.fromARGB(255, 108, 140, 109),
                    Colors.purple,
                    Colors.blue,
                    Colors.orange,
                    Colors.red,
                    Colors.teal,
                  ];

                  int i = 0;
                  categoryMap.forEach((key, value) {
                    sections.add(
                      PieChartSectionData(
                        value: value,
                        color: colors[i % colors.length],
                        title: key,
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    );
                    i++;
                  });

                  return Column(
                    children: [

                      _summaryCard("Income", income, Colors.green),
                      const SizedBox(height: 10),
                      _summaryCard("Expense", expense, Colors.red),
                      const SizedBox(height: 10),
                      _summaryCard("Balance", balance, Colors.blueGrey),

                      const SizedBox(height: 20),

                      /// 🔥 BUDGET SUMMARY (REAL)
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("user")
                            .doc(uid)
                            .collection("budgets")
                            .snapshots(),
                        builder: (context, bSnap) {

                          if (!bSnap.hasData) {
                            return const SizedBox();
                          }

                          double total = 0;
                          double used = 0;

                          for (var doc in bSnap.data!.docs) {
                            final data = doc.data() as Map<String, dynamic>;

                            total += (data["amount"] ?? 0).toDouble();
                            used += (data["used"] ?? 0).toDouble();
                          }

                          double percent =
                              total > 0 ? used / total : 0;

                          return Container(
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
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),

                                const SizedBox(height: 10),

                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: percent.clamp(0, 1),
                                    minHeight: 10,
                                    color: Colors.purple,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  "ใช้ไป ${(percent * 100).toStringAsFixed(0)}%",
                                  style: const TextStyle(
                                      color: Colors.red),
                                )
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      /// 🔥 PIE CHART (REAL)
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
                                style: TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),

                            const SizedBox(height: 20),

                            SizedBox(
                              height: 200,
                              child: PieChart(
                                PieChartData(
                                  sections: sections.isEmpty
                                      ? [
                                          PieChartSectionData(
                                            value: 1,
                                            color: Colors.grey,
                                            title: "No Data",
                                          )
                                        ]
                                      : sections,
                                ),
                              ),
                            )
                          ],
                        ),
                      )

                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String title, double value, Color color) {
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
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("฿ ${value.toStringAsFixed(0)}")
        ],
      ),
    );
  }
}