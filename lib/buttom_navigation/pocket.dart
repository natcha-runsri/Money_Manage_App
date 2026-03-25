import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/transaction.dart';
import '../data/bill.dart';
import '../data/budget.dart';

class PocketPage extends StatelessWidget {
  const PocketPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xffF6F3F5),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              /// USER HEADER
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage("images/avatar.png"),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: StreamBuilder<DocumentSnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection("user")
                                .doc(uid)
                                .snapshots(),

                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Text("Loading...");
                          }

                          final data =
                              snapshot.data!.data() as Map<String, dynamic>;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data["username"] ?? "UserName",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              Text(data["accountName"] ?? "Account Name"),

                              const SizedBox(height: 5),

                              StreamBuilder<QuerySnapshot>(
                                stream:
                                    FirebaseFirestore.instance
                                        .collection("user")
                                        .doc(uid)
                                        .collection("transactions")
                                        .snapshots(),

                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Text("ยอดเงินคงเหลือ 0");
                                  }

                                  double income = 0;
                                  double expense = 0;

                                  for (var doc in snapshot.data!.docs) {
                                    final d =
                                        doc.data() as Map<String, dynamic>;

                                    double amount =
                                        (d["amount"] as num).toDouble();

                                    if (d["type"] == "income") {
                                      income += amount;
                                    } else {
                                      expense += amount;
                                    }
                                  }

                                  double balance = income - expense;

                                  return Text(
                                    "ยอดเงินคงเหลือ ฿${balance.toStringAsFixed(0)}",
                                    style: const TextStyle(
                                      color: Color(0xff8B3A5A),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// ACCOUNT CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.wallet),
                        SizedBox(width: 10),
                        Text(
                          "Your Account",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection("user")
                              .doc(uid)
                              .collection("transactions")
                              .snapshots(),

                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Text("ยอดเงินในกระเป๋า 0");
                        }

                        double income = 0;
                        double expense = 0;

                        for (var doc in snapshot.data!.docs) {
                          final d = doc.data() as Map<String, dynamic>;

                          double amount = (d["amount"] as num).toDouble();

                          if (d["type"] == "income") {
                            income += amount;
                          } else {
                            expense += amount;
                          }
                        }

                        double balance = income - expense;

                        return Text(
                          "ยอดเงินในกระเป๋า ฿${balance.toStringAsFixed(0)}",
                          style: const TextStyle(
                            color: Color(0xff8B3A5A),
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// TRANSACTION CARD
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TransactionPage()),
                  );
                },

                child: Container(
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
                        children: const [
                          Text(
                            "Your Transaction",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                      const SizedBox(height: 12),
                      StreamBuilder<QuerySnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection("user")
                                .doc(uid)
                                .collection("transactions")
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Text("Loading...");
                          }

                          double income = 0;
                          double expense = 0;

                          for (var doc in snapshot.data!.docs) {
                            final d = doc.data() as Map<String, dynamic>;

                            double amount = (d["amount"] ?? 0).toDouble();

                            if (d["type"] == "income") {
                              income += amount;
                            } else {
                              expense += amount;
                            }
                          }

                          double balance = income - expense;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "รายรับ: ฿${income.toStringAsFixed(0)}",
                                    ),
                                  ),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "รายจ่าย: -฿${expense.toStringAsFixed(0)}",
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              Text("คงเหลือ: ฿${balance.toStringAsFixed(0)}"),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// BUDGET CARD
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BudgetPage()),
                  );
                },

                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: const [
                          Text(
                            "Your Budget",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),

                      const SizedBox(height: 10),

                      StreamBuilder<QuerySnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection("user")
                                .doc(uid)
                                .collection("budgets")
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Text("Monthly Budget ฿0");
                          }

                          double totalBudget = 0;

                          for (var doc in snapshot.data!.docs) {
                            final data = doc.data() as Map<String, dynamic>;
                            totalBudget += (data["amount"] ?? 0).toDouble();
                          }

                          return Text(
                            "Monthly Budget ฿${totalBudget.toStringAsFixed(0)}",
                          );
                        },
                      ),

                      const SizedBox(height: 8),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),

                        child: StreamBuilder<QuerySnapshot>(
                          stream:
                              FirebaseFirestore.instance
                                  .collection("user")
                                  .doc(uid)
                                  .collection("transactions")
                                  .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const LinearProgressIndicator(value: 0);
                            }

                            double expense = 0;

                            for (var doc in snapshot.data!.docs) {
                              final data = doc.data() as Map<String, dynamic>;

                              if (data["type"] == "expense") {
                                expense += (data["amount"] ?? 0).toDouble();
                              }
                            }

                            double percent = 0;

                            return StreamBuilder<QuerySnapshot>(
                              stream:
                                  FirebaseFirestore.instance
                                      .collection("user")
                                      .doc(uid)
                                      .collection("budgets")
                                      .snapshots(),
                              builder: (context, snapshot2) {
                                if (!snapshot2.hasData) {
                                  return const LinearProgressIndicator(
                                    value: 0,
                                  );
                                }

                                double budget = 0;

                                for (var doc in snapshot2.data!.docs) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  budget += (data["amount"] ?? 0).toDouble();
                                }

                                if (budget > 0) {
                                  percent = expense / budget;
                                }

                                return LinearProgressIndicator(
                                  value: percent.clamp(0, 1),
                                  minHeight: 8,
                                  backgroundColor: Colors.grey,
                                  color: Colors.red,
                                );
                              },
                            );
                          },
                        ),
                      ),

                      StreamBuilder<QuerySnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection("user")
                                .doc(uid)
                                .collection("budgets")
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Text("กำลังโหลด...");
                          }

                          double totalBudget = 0;

                          for (var doc in snapshot.data!.docs) {
                            final data = doc.data() as Map<String, dynamic>;
                            totalBudget += (data["amount"] ?? 0).toDouble();
                          }

                          return StreamBuilder<QuerySnapshot>(
                            stream:
                                FirebaseFirestore.instance
                                    .collection("user")
                                    .doc(uid)
                                    .collection("transactions")
                                    .snapshots(),
                            builder: (context, snapshot2) {
                              if (!snapshot2.hasData) {
                                return const Text("กำลังโหลด...");
                              }

                              double expense = 0;

                              for (var doc in snapshot2.data!.docs) {
                                final data = doc.data() as Map<String, dynamic>;

                                if (data["type"] == "expense") {
                                  expense += (data["amount"] ?? 0).toDouble();
                                }
                              }

                              double remain = totalBudget - expense;

                              return Text(
                                "คุณใช้ Budget เหลืออีก ${remain.toStringAsFixed(0)} บาท",
                                style: TextStyle(
                                  color: remain < 0 ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// BILL CARD
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BillPage()),
                  );
                },

                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: const [
                          Text(
                            "Your Bill",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),

                      const SizedBox(height: 10),

                      StreamBuilder<QuerySnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection("user")
                                .doc(uid)
                                .collection("bills")
                                .orderBy("date")
                                .limit(1)
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Text("No Bill");
                          }

                          final data =
                              snapshot.data!.docs.first.data()
                                  as Map<String, dynamic>;

                          Timestamp ts = data["date"];
                          DateTime d = ts.toDate();

                          return Text(
                            "Next Due: ${d.day}/${d.month}/${d.year}",
                          );
                        },
                      ),

                      const SizedBox(height: 6),

                      StreamBuilder<QuerySnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection("user")
                                .doc(uid)
                                .collection("bills")
                                .orderBy("date")
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Text("No Bill");
                          }

                          final bills = snapshot.data!.docs;

                          double total = 0;

                          for (var doc in bills) {
                            final data = doc.data() as Map<String, dynamic>;

                            if (data["status"] != "ชำระแล้ว") {
                              total += (data["amount"] ?? 0).toDouble();
                            }
                          }

                          final nextBill =
                              bills.first.data() as Map<String, dynamic>;

                          Timestamp ts = nextBill["date"];
                          DateTime d = ts.toDate();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Next Due: ${d.day}/${d.month}/${d.year}"),

                              const SizedBox(height: 6),

                              Text(
                                "฿${nextBill["amount"]}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xff8B3A5A),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "ที่ต้องจ่าย: ฿${total.toStringAsFixed(0)}",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
