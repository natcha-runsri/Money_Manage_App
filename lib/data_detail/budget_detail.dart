import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BudgetDetailPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const BudgetDetailPage({super.key, required this.docId, required this.data});

  @override
  State<BudgetDetailPage> createState() => _BudgetDetailPageState();
}

class _BudgetDetailPageState extends State<BudgetDetailPage> {
  final nameController = TextEditingController();
  final amountController = TextEditingController();

  bool alerted = false;
  bool isEdit = false;

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    // โหลดค่าจาก data
    startDate =
        (widget.data["start_date"] as Timestamp?)?.toDate() ??
            DateTime.now();

    endDate =
        (widget.data["end_date"] as Timestamp?)?.toDate() ??
            DateTime.now();

    nameController.text = widget.data["name"] ?? "";
    amountController.text = (widget.data["amount"] ?? 0).toString();
  }

  /// UPDATE
  Future<void> updateBudget() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    double newAmount = double.tryParse(amountController.text) ?? 0;

    await FirebaseFirestore.instance
        .collection("user")
        .doc(uid)
        .collection("budgets")
        .doc(widget.docId)
        .update({
      "name": nameController.text,
      "amount": newAmount,
      "start_date": Timestamp.fromDate(startDate),
      "end_date": Timestamp.fromDate(endDate),
    });

    Navigator.pop(context);
  }

  /// DELETE
  Future<void> deleteBudget() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection("user")
        .doc(uid)
        .collection("budgets")
        .doc(widget.docId)
        .delete();

    Navigator.pop(context);
  }

  void confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Budget"),
        content: const Text("ต้องการลบงบนี้หรือไม่"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteBudget();
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    DateTime now = DateTime.now();
    DateTime startMonth = DateTime(now.year, now.month, 1);
    DateTime endMonth = DateTime(now.year, now.month + 1, 1);

    double lastSpent = 0;

    return Scaffold(
      appBar: AppBar(title: const Text("Budget Detail")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// NAME
            TextField(
              controller: nameController,
              enabled: isEdit,
              decoration: const InputDecoration(labelText: "Budget Name"),
            ),

            const SizedBox(height: 10),

            /// AMOUNT
            TextField(
              controller: amountController,
              enabled: isEdit,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount"),
            ),

            const SizedBox(height: 10),

            /// START DATE
            GestureDetector(
              onTap: isEdit
                  ? () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );

                      if (picked != null) {
                        setState(() {
                          startDate = picked;
                        });
                      }
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: isEdit ? Colors.blue : Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        "Start: ${startDate.toLocal()}".split(' ')[0]),
                    const Icon(Icons.calendar_month),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// END DATE
            GestureDetector(
              onTap: isEdit
                  ? () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: endDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );

                      if (picked != null) {
                        setState(() {
                          endDate = picked;
                        });
                      }
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: isEdit ? Colors.blue : Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("End: ${endDate.toLocal()}".split(' ')[0]),
                    const Icon(Icons.calendar_month),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// SUMMARY + STREAM
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("user")
                  .doc(uid)
                  .collection("budgets")
                  .doc(widget.docId)
                  .snapshots(),
              builder: (context, budgetSnap) {
                if (!budgetSnap.hasData || !budgetSnap.data!.exists) {
                  return const Center(child: Text("ไม่พบข้อมูล budget"));
                }

                final budgetData =
                    budgetSnap.data!.data() as Map<String, dynamic>;

                double limit =
                    (budgetData["amount"] ?? 0).toDouble();

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("user")
                      .doc(uid)
                      .collection("transactions")
                      .where("budgetId", isEqualTo: widget.docId)
                      .where("type", isEqualTo: "expense")
                      .where("date",
                          isGreaterThanOrEqualTo: startMonth)
                      .where("date", isLessThan: endMonth)
                      .snapshots(),
                  builder: (context, transSnap) {
                    double spent = lastSpent;

                    if (transSnap.hasData &&
                        transSnap.data != null) {
                      spent = 0;

                      for (var doc in transSnap.data!.docs) {
                        final data =
                            doc.data() as Map<String, dynamic>;
                        spent +=
                            (data["amount"] ?? 0).toDouble();
                      }

                      lastSpent = spent;
                    }

                    double percent =
                        limit > 0 ? spent / limit : 0;
                    double remain = limit - spent;

                    return Column(
                      children: [
                        LinearProgressIndicator(
                          value: percent.clamp(0, 1),
                          minHeight: 10,
                        ),
                        const SizedBox(height: 10),
                        Text("Spent ฿$spent / ฿$limit"),
                        Text(
                          "Remaining ฿$remain",
                          style: TextStyle(
                            color: remain < 0
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            /// BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (isEdit) {
                        updateBudget();
                      } else {
                        setState(() {
                          isEdit = true;
                        });
                      }
                    },
                    child: Text(isEdit ? "Save" : "Edit"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: confirmDelete,
                    child: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}