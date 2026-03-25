import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionDetailPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const TransactionDetailPage({
    super.key,
    required this.docId,
    required this.data,
  });

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  final nameController = TextEditingController();
  final categoryController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  bool isEdit = false;

  @override
  void initState() {
    super.initState();

    nameController.text = widget.data["name"] ?? "";
    categoryController.text = widget.data["category"] ?? "";
    amountController.text = widget.data["amount"].toString();
    noteController.text = widget.data["note"] ?? "";

    Timestamp ts = widget.data["date"];
    selectedDate = ts.toDate();
  }

  Future<void> updateTransaction() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  final oldAmount = (widget.data["amount"] ?? 0).toDouble();
  final newAmount = double.parse(amountController.text);

  final oldCategory = widget.data["category"];
  final newCategory = categoryController.text;

  

  final batch = FirebaseFirestore.instance.batch();

  final transactionRef = FirebaseFirestore.instance
      .collection("user")
      .doc(uid)
      .collection("transactions")
      .doc(widget.docId);

  //  update transaction
  batch.update(transactionRef, {
    "name": nameController.text,
    "category": newCategory,
    "amount": newAmount,
    "note": noteController.text,
    "date": Timestamp.fromDate(selectedDate),
  });

  //  budget เดิม
  final oldBudgetQuery = await FirebaseFirestore.instance
      .collection("user")
      .doc(uid)
      .collection("budgets")
      .where("category", isEqualTo: oldCategory)
      .limit(1)
      .get();

  // หา budget ใหม่
  final newBudgetQuery = await FirebaseFirestore.instance
      .collection("user")
      .doc(uid)
      .collection("budgets")
      .where("category", isEqualTo: newCategory)
      .limit(1)
      .get();

  // กรณี category เดิม
  if (oldCategory == newCategory) {
    final diff = newAmount - oldAmount;

    if (oldBudgetQuery.docs.isNotEmpty) {
      final budgetRef = oldBudgetQuery.docs.first.reference;

      batch.update(budgetRef, {
        "used": FieldValue.increment(diff),
      });
    }
  } else {
    // เปลี่ยน category

    // ลบออกจาก budget เก่า
    if (oldBudgetQuery.docs.isNotEmpty) {
      batch.update(oldBudgetQuery.docs.first.reference, {
        "used": FieldValue.increment(-oldAmount),
      });
    }

    // เพิ่มเข้า budget ใหม่
    if (newBudgetQuery.docs.isNotEmpty) {
      batch.update(newBudgetQuery.docs.first.reference, {
        "used": FieldValue.increment(newAmount),
      });
    }
  }

  await batch.commit();

  Navigator.pop(context);
}
  Future<void> pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Future<void> deleteTransaction() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  final amount = (widget.data["amount"] ?? 0).toDouble();
  final budgetId = widget.data["budgetId"]; // ✅ ใช้ id แทน category

  final batch = FirebaseFirestore.instance.batch();

  final transactionRef = FirebaseFirestore.instance
      .collection("user")
      .doc(uid)
      .collection("transactions")
      .doc(widget.docId);

  final budgetRef = FirebaseFirestore.instance
      .collection("user")
      .doc(uid)
      .collection("budgets")
      .doc(budgetId);

  // ลบ transaction
  batch.delete(transactionRef);

  // ลด used แบบ 100% ตรงตัว
  batch.update(budgetRef, {
    "used": FieldValue.increment(-amount),
  });

  await batch.commit();

  Navigator.pop(context);
}

  void confirmDelete() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Transaction"),
          content: const Text("คุณต้องการลบรายการนี้หรือไม่"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deleteTransaction();
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("transaction")),

      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection("user")
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection("transactions")
                .doc(widget.docId)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return const Center(child: Text("Transaction not found"));
          }

          final rawData = snapshot.data!.data();

          if (rawData == null) {
            return const Center(child: Text("No data"));
          }

          final data = rawData as Map<String, dynamic>;
          if (!isEdit) {
            nameController.text = data["name"] ?? "";
            categoryController.text = data["category"] ?? "";
            amountController.text = data["amount"].toString();
            noteController.text = data["note"] ?? "";

            Timestamp ts = data["date"];
            selectedDate = ts.toDate();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              data["type"] == "income"
                                  ? Colors.green
                                  : Colors.red,
                              data["type"] == "income"
                                  ? Colors.green.shade300
                                  : Colors.red.shade300,
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data["type"] == "income" ? "Income" : "Expense",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "${_formatMoney(data["amount"])} ฿",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// NAME
                      const Text("TransactionName"),
                      const SizedBox(height: 8),

                      TextField(
                        controller: nameController,
                        enabled: isEdit,
                        decoration: _input(),
                      ),

                      const SizedBox(height: 20),

                      /// CATEGORY
                      const Text("Category"),
                      const SizedBox(height: 8),

                      TextField(
                        controller: categoryController,
                        enabled: isEdit,
                        decoration: _input(),
                      ),

                      const SizedBox(height: 20),

                      /// DATE
                      const Text("Date"),
                      const SizedBox(height: 8),

                      GestureDetector(
                        onTap: isEdit ? pickDate : null,
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: _box(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${selectedDate.toLocal()}".split(' ')[0]),
                              const Icon(Icons.calendar_month),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// AMOUNT
                      const Text("Amount"),
                      const SizedBox(height: 8),

                      TextField(
                        controller: amountController,
                        enabled: isEdit,
                        keyboardType: TextInputType.number,
                        decoration: _input(suffix: "\$"),
                      ),

                      const SizedBox(height: 20),

                      /// NOTE
                      const Text("Note"),
                      const SizedBox(height: 8),

                      TextField(
                        controller: noteController,
                        enabled: isEdit,
                        maxLines: 3,
                        decoration: _input(),
                      ),

                      const SizedBox(height: 20),

                      /// BUTTONS
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isEdit) {
                        updateTransaction();
                      } else {
                        setState(() {
                          isEdit = true;
                        });
                      }
                    },
                    child: Text(isEdit ? "Save" : "Edit"),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
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
              ],
            ),
          );
        },
      ),
    );
  }

  InputDecoration _input({String? suffix}) {
    return InputDecoration(
      suffixText: suffix,
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  BoxDecoration _box() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade300),
    );
  }
}

String _formatMoney(num amount) {
  return amount
      .toStringAsFixed(2)
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
}
