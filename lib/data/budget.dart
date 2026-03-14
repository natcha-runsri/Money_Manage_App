import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  String searchText = "";
  bool showBudget = true;

  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F3F5),

      appBar: AppBar(title: const Text("Budget"), centerTitle: true),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// MONTHLY SUMMARY
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection("user")
                      .doc(uid)
                      .collection(showBudget ? "budgets" : "saving_goals")
                      .snapshots(),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                }

                double totalLimit = 0;
                double totalSpent = 0;

                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;

                  totalLimit += (data["amount"] ?? 0).toDouble();
                }

                double percent = 0;

                if (totalLimit > 0) {
                  percent = totalSpent / totalLimit;
                }
                return Container(
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Monthly Budget ฿${totalLimit.toStringAsFixed(0)}",
                          ),

                          Text(
                            "${(percent * 100).toStringAsFixed(0)}%",
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),

                        child: LinearProgressIndicator(
                          value: percent,
                          minHeight: 10,
                          backgroundColor: Colors.grey.shade300,
                          color: Colors.red,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "คุณมี Budget เหลืออีก ${(totalLimit - totalSpent).toStringAsFixed(0)} บาท",
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            /// TOGGLE
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        showBudget = true;
                      });
                    },

                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),

                      decoration: BoxDecoration(
                        color:
                            showBudget
                                ? const Color(0xff1E3A8A)
                                : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: const Center(
                        child: Text(
                          "Budgets",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// SEARCH
            TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },

              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: const Icon(Icons.calendar_today),
                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// LIST
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection("user")
                        .doc(uid)
                        .collection("budgets")
                        .snapshots(),

                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs =
                      snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;

                        return data["name"].toLowerCase().contains(
                          searchText.toLowerCase(),
                        );
                      }).toList();

                  if (docs.isEmpty) {
                    return const Center(child: Text("No budget"));
                  }

                  return ListView.builder(
                    itemCount: docs.length,

                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;

                      double limit = (data["amount"] ?? 0).toDouble();
                      double spent = 0; // ถ้ายังไม่ได้คำนวณจาก transaction

                      double percent = 0;

                      if (limit > 0) {
                        percent = spent / limit;
                      }

                      bool close = percent > 0.8;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),

                        padding: const EdgeInsets.all(14),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor:
                                          close ? Colors.red : Colors.green,

                                      child: const Icon(
                                        Icons.category,
                                        color: Colors.white,
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: [
                                        Text(
                                          data["name"],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        Text(
                                          "฿${spent.toStringAsFixed(0)} spent of ฿${limit.toStringAsFixed(0)}",
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),

                                  decoration: BoxDecoration(
                                    color: close ? Colors.red : Colors.green,
                                    borderRadius: BorderRadius.circular(20),
                                  ),

                                  child: Text(
                                    close ? "Close to Limit" : "On track",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),

                              child: LinearProgressIndicator(
                                value: percent,
                                minHeight: 8,
                                backgroundColor: Colors.grey.shade300,
                                color: close ? Colors.red : Colors.green,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              "You've used ${(percent * 100).toStringAsFixed(0)}% of your budget",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
