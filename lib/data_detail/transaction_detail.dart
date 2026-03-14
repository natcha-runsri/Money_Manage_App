import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    await FirebaseFirestore.instance
        .collection("user")
        .doc(widget.data["uid"])
        .collection("transactions")
        .doc(widget.docId)
        .update({
          "name": nameController.text,
          "category": categoryController.text,
          "amount": double.parse(amountController.text),
          "note": noteController.text,
          "date": Timestamp.fromDate(selectedDate),
        });

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
    await FirebaseFirestore.instance
        .collection("user")
        .doc(widget.data["uid"])
        .collection("transactions")
        .doc(widget.docId)
        .delete();

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

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            const Spacer(),

            /// BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Column(
                children: [
                  /// EDIT
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff3F5576),
                      ),
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

                  /// DELETE
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: confirmDelete,
                      child: const Text("Delete"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _input({String? suffix}) {
    return InputDecoration(
      suffixText: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  BoxDecoration _box() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade300),
    );
  }
}
