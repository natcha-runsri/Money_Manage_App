import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  DateTime selectedDate = DateTime.now();

  String selectedCategory = "Travel";
  String type = "expense";

  final nameController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  /// EXPENSE
  List<Map<String, dynamic>> expenseCategories = [
    {"name": "Travel", "icon": Icons.flight},
    {"name": "Home", "icon": Icons.home},
    {"name": "Bills", "icon": Icons.receipt},
    {"name": "Food", "icon": Icons.restaurant},
    {"name": "Shopping", "icon": Icons.shopping_bag},
  ];

  /// INCOME
  List<Map<String, dynamic>> incomeCategories = [
    {"name": "Salary", "icon": Icons.attach_money},
    {"name": "Bonus", "icon": Icons.card_giftcard},
    {"name": "Gift", "icon": Icons.redeem},
  ];

  /// SAVE
  Future<void> addTransaction() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    double amount = double.parse(amountController.text.replaceAll(",", ""));

    await FirebaseFirestore.instance
        .collection("user")
        .doc(uid)
        .collection("transactions")
        .add({
          "type": type,
          "name": nameController.text,
          "category": selectedCategory,
          "amount": amount,
          "note": noteController.text,
          "date": Timestamp.fromDate(selectedDate),
        });
  }

  /// DATE PICKER
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

  /// CATEGORY POPUP
  void openCategoryPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select Category",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              /// EXPENSE
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Expense",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 10,
                children:
                    expenseCategories.map((cat) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = cat["name"];
                            type = "expense";
                          });
                          Navigator.pop(context);
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                          child: Icon(cat["icon"], color: Colors.white),
                        ),
                      );
                    }).toList(),
              ),

              const SizedBox(height: 20),

              /// INCOME
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Income",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 10,
                children:
                    incomeCategories.map((cat) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = cat["name"];
                            type = "income";
                          });
                          Navigator.pop(context);
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(cat["icon"], color: Colors.white),
                        ),
                      );
                    }).toList(),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color typeColor = type == "expense" ? Colors.red : Colors.green;

    return Scaffold(
      appBar: AppBar(title: const Text("Add Transaction"), centerTitle: true),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TRANSACTION NAME
            const Text("Transaction Name"),
            const SizedBox(height: 8),

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "Enter name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// DATE
            const Text("Date"),
            const SizedBox(height: 8),

            GestureDetector(
              onTap: pickDate,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
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

            /// CATEGORY
            const Text("Category"),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: openCategoryPopup,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: typeColor,
                      child: const Icon(Icons.category, color: Colors.white),
                    ),

                    const SizedBox(width: 10),

                    Text(
                      selectedCategory,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: typeColor,
                      ),
                    ),

                    const Spacer(),

                    const Icon(Icons.arrow_forward_ios, size: 16),
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
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter Amount",
                suffixText: "฿",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// NOTE
            const Text("Note"),
            const SizedBox(height: 8),

            TextField(
              controller: noteController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Additional notes",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const Spacer(),

            /// SAVE
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff3F5576),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (amountController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("กรุณากรอกจำนวนเงิน")),
                    );
                    return;
                  }

                  try {
                    await addTransaction();

                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("เกิดข้อผิดพลาด $e")),
                    );
                  }
                },
                child: const Text(
                  "Save",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
