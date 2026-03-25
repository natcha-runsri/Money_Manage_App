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
  IconData selectedIcon = Icons.flight;
  Color selectedColor = Colors.red;
  String selectedBudgetId = "";

  final nameController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  // EXPENSE
  List<Map<String, dynamic>> expenseCategories = [
    {"name": "Travel", "icon": Icons.flight, "color": Colors.red},
    {"name": "Home", "icon": Icons.home, "color": Colors.green},
    {"name": "Bills", "icon": Icons.receipt, "color": Colors.blue},
    {"name": "Food", "icon": Icons.restaurant, "color": Colors.orange},
    {"name": "Shopping", "icon": Icons.shopping_bag, "color": Colors.purple},
    {"name": "Pet", "icon": Icons.pets, "color": Colors.brown},
    {"name": "Health", "icon": Icons.favorite, "color": Colors.pink},
  ];

  // INCOME
  List<Map<String, dynamic>> incomeCategories = [
    {"name": "Salary", "icon": Icons.attach_money, "color": Colors.green},
    {"name": "Bonus", "icon": Icons.card_giftcard, "color": Colors.blue},
    {"name": "Gift", "icon": Icons.redeem, "color": Colors.pink},
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
          "icon": selectedIcon.codePoint,
          "color": selectedColor.value,
          "amount": amount,
          "note": noteController.text,
          "date": Timestamp.fromDate(selectedDate),
          "budgetId": selectedBudgetId,
        });

    await FirebaseFirestore.instance
        .collection("user")
        .doc(uid)
        .collection("notifications")
        .add({
          "title": "มีรายการใหม่",
          "message": "คุณเพิ่มรายการ ${nameController.text}",
          "type": "transaction",
          "created_at": Timestamp.now(),
          "isRead": false,
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

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    bool isLoading = false;
    return Scaffold(
      appBar: AppBar(title: const Text("Add Transaction"), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const Text("Category", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          type = "expense";
                          selectedCategory = expenseCategories[0]["name"];
                          selectedIcon = expenseCategories[0]["icon"];
                          selectedColor = expenseCategories[0]["color"];
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              type == "expense"
                                  ? Colors.red
                                  : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            "Expense",
                            style: TextStyle(
                              color:
                                  type == "expense"
                                      ? Colors.white
                                      : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          type = "income";
                          selectedCategory = incomeCategories[0]["name"];
                          selectedIcon = incomeCategories[0]["icon"];
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              type == "income"
                                  ? Colors.green
                                  : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            "Income",
                            style: TextStyle(
                              color:
                                  type == "income"
                                      ? Colors.white
                                      : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children:
                    (type == "expense" ? expenseCategories : incomeCategories)
                        .map((cat) {
                          bool isSelected = selectedCategory == cat["name"];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCategory = cat["name"];
                                selectedIcon = cat["icon"];
                                selectedColor = cat["color"];
                              });
                            },
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? (type == "expense"
                                                ? Colors.red
                                                : Colors.green)
                                            : Colors.grey.shade200,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    cat["icon"],
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  cat["name"],
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        })
                        .toList(),
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

              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection("user")
                        .doc(uid)
                        .collection("budgets")
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();

                  final budgets = snapshot.data!.docs;

                  return DropdownButton<String>(
                    value: selectedBudgetId.isEmpty ? null : selectedBudgetId,
                    hint: Text("เลือก Budget"),
                    items:
                        budgets.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return DropdownMenuItem(
                            value: doc.id,
                            child: Text(data["name"] ?? ""),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBudgetId = value!;
                      });
                    },
                  );
                },
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

              const SizedBox(height: 20),

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
                    if (nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("กรุณากรอกชื่อรายการ")),
                      );
                      return;
                    }

                    if (amountController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("กรุณากรอกจำนวนเงิน")),
                      );
                      return;
                    }

                    if (selectedBudgetId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("กรุณาเลือก Budget")),
                      );
                      return;
                    }

                    try {
                      double amount = double.parse(amountController.text);

                      await addTransaction();

                      if (type == "expense") {
                        await updateBudget(selectedBudgetId, amount);
                      }

                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("error $e")));
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
      ),
    );
  }
}

Future<void> updateBudget(String budgetId, double amount) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  final doc =
      await FirebaseFirestore.instance
          .collection("user")
          .doc(uid)
          .collection("budgets")
          .doc(budgetId)
          .get();

  if (!doc.exists) return;

  final data = doc.data() as Map<String, dynamic>;

  double used = (data["used"] ?? 0).toDouble();
  double total = (data["amount"]).toDouble();

  double newUsed = used + amount;
  double remaining = total - newUsed;

  String status = newUsed >= total ? "exceeded" : "active";

  await doc.reference.update({
    "used": newUsed,
    "remaining": remaining,
    "status": status,
  });

  /// 🔔 แจ้งเตือน 80%
  if (newUsed / total >= 0.8 && data["alert"] != true) {
    await FirebaseFirestore.instance
        .collection("user")
        .doc(uid)
        .collection("notifications")
        .add({
          "title": "งบใกล้เต็ม",
          "message": "งบ ${data["name"]} ใช้ไปเกิน 80%",
          "created_at": Timestamp.now(),
          "isRead": false,
        });

    await doc.reference.update({"alert": true});
  }
}
