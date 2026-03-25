import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BillPage extends StatefulWidget {
  const BillPage({super.key});

  @override
  State<BillPage> createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  String selectedTab = "weekly";
  String searchText = "";

  DateTime now = DateTime.now();

  DateTime get startDate {
    if (selectedTab == "daily") {
      return DateTime(now.year, now.month, now.day);
    } else if (selectedTab == "weekly") {
      return now.subtract(Duration(days: now.weekday - 1));
    } else {
      return DateTime(now.year, now.month, 1);
    }
  }

  DateTime get endDate {
    if (selectedTab == "daily") {
      return startDate.add(const Duration(days: 1));
    } else if (selectedTab == "weekly") {
      return startDate.add(const Duration(days: 7));
    } else {
      return DateTime(now.year, now.month + 1, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xffF6F3F5),

      appBar: AppBar(
        title: const Text("Bill"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// 🔥 TAB
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  _tab("Daily"),
                  _tab("Weekly"),
                  _tab("Monthly"),
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// 🔍 SEARCH
            TextField(
              onChanged: (value) {
                setState(() => searchText = value);
              },
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// 🔥 DATA FROM BILLS
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("user")
                    .doc(uid)
                    .collection("bills")
                    .where("date",
                        isGreaterThanOrEqualTo:
                            Timestamp.fromDate(startDate))
                    .where("date",
                        isLessThan:
                            Timestamp.fromDate(endDate))
                    .orderBy("date", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {

                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs.where((doc) {
                    final data =
                        doc.data() as Map<String, dynamic>;

                    return (data["bill_name"] ?? "")
                        .toLowerCase()
                        .contains(searchText.toLowerCase());
                  }).toList();

                  double total = 0;
                  double paid = 0;

                  for (var doc in docs) {
                    final data =
                        doc.data() as Map<String, dynamic>;

                    double amount =
                        (data["amount"] ?? 0).toDouble();

                    total += amount;

                    if (data["status"] == "paid") {
                      paid += amount;
                    }
                  }

                  double balance = total - paid;

                  return Column(
                    children: [

                      /// SUMMARY
                      Container(
                         width: double.infinity, 
                        padding: const EdgeInsets.all(16),
                        margin:
                            const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xffEADCE3),
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            Text(
                              "${startDate.day}/${startDate.month} - ${endDate.day}/${endDate.month}",
                            ),

                            const SizedBox(height: 6),

                            Text("Total ฿${total.toStringAsFixed(0)}"),

                            Text(
                              "Paid ฿${paid.toStringAsFixed(0)}",
                              style: const TextStyle(color: Colors.green),
                            ),

                            Text(
                              "Unpaid ฿${balance.toStringAsFixed(0)}",
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),

                      /// LIST
                      Expanded(
                        child: docs.isEmpty
                            ? const Center(
                                child: Text("ไม่มีบิล"))
                            : ListView.builder(
                                itemCount: docs.length,
                                itemBuilder: (context, index) {
                                  final data = docs[index]
                                      .data() as Map<String, dynamic>;

                                  bool isPaid =
                                      data["status"] == "paid";

                                  return Container(
                                    margin: const EdgeInsets.only(
                                        bottom: 10),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      children: [

                                        CircleAvatar(
                                          backgroundColor: isPaid
                                              ? Colors.green
                                              : Colors.red,
                                          child: const Icon(
                                            Icons.receipt,
                                            color: Colors.white,
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                data["bill_name"] ?? "",
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                data["note"] ?? "",
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              "฿${data["amount"]}",
                                              style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold),
                                            ),
                                            Text(
                                              isPaid
                                                  ? "Paid"
                                                  : "Unpaid",
                                              style: TextStyle(
                                                color: isPaid
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                      )
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _tab(String title) {
    bool active =
        selectedTab == title.toLowerCase();

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = title.toLowerCase();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? const Color(0xff8B3A5A)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color:
                    active ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}