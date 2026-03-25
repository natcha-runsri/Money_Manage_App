import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BillDetailPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const BillDetailPage({super.key, required this.docId, required this.data});

  @override
  State<BillDetailPage> createState() => _BillDetailPageState();
}

class _BillDetailPageState extends State<BillDetailPage> {
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  String status = "ยังไม่ชำระ";
  bool isEdit = false;

  @override
  @override
  void initState() {
    super.initState();

    nameController.text = (widget.data["bill_name"] ?? "").toString();
    noteController.text = (widget.data["note"] ?? "").toString();
    amountController.text = (widget.data["amount"] ?? 0).toString();
    status = widget.data["status"] ?? "ยังไม่ชำระ";

    if (!["ยังไม่ชำระ", "ชำระแล้ว"].contains(status)) {
      status = "ยังไม่ชำระ";
    }
  }

  /// UPDATE
  Future<void> updateBill() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection("user")
        .doc(uid)
        .collection("bills")
        .doc(widget.docId)
        .update({
          "bill_name": nameController.text,
          "amount": double.tryParse(amountController.text) ?? 0,
          "note": noteController.text,
          "status": status,
        });

    Navigator.pop(context);
  }

  /// DELETE
  Future<void> deleteBill() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection("user")
        .doc(uid)
        .collection("bills")
        .doc(widget.docId)
        .delete();

    Navigator.pop(context);
  }

  /// CONFIRM DELETE
  void confirmDelete() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Delete Bill"),
            content: const Text("ต้องการลบรายการนี้หรือไม่"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  deleteBill();
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
    return Scaffold(
      appBar: AppBar(title: const Text("Bill Detail")),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// NAME
            TextField(
              controller: nameController,
              enabled: isEdit,
              decoration: const InputDecoration(labelText: "Bill Name"),
            ),

            const SizedBox(height: 15),

            /// AMOUNT
            TextField(
              controller: amountController,
              enabled: isEdit,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount"),
            ),

            const SizedBox(height: 15),

            /// STATUS
            DropdownButtonFormField<String>(
              value:
                  ["ยังไม่ชำระ", "ชำระแล้ว"].contains(status)
                      ? status
                      : "ยังไม่ชำระ",
              items: const [
                DropdownMenuItem(
                  value: "ยังไม่ชำระ",
                  child: Text("ยังไม่ชำระ"),
                ),
                DropdownMenuItem(value: "ชำระแล้ว", child: Text("ชำระแล้ว")),
              ],
              onChanged:
                  isEdit
                      ? (v) {
                        setState(() {
                          if (v != null) {
                            status = v;
                          }
                        });
                      }
                      : null,
              decoration: const InputDecoration(labelText: "Status"),
            ),

            const SizedBox(height: 15),

            /// NOTE
            TextField(
              controller: noteController,
              enabled: isEdit,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Note"),
            ),

            const SizedBox(height: 30),

            /// BUTTONS
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isEdit) {
                        updateBill();
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
    );
  }
}
