import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddSchedulePage extends StatefulWidget {
  const AddSchedulePage({super.key});

  @override
  State<AddSchedulePage> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {

  DateTime selectedDate = DateTime.now();

  final billController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  String status = "ยังไม่ชำระ";
  bool reminder = false;

  /// DATE PICKER
  Future<void> pickDate() async {

    DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if(date != null){
      setState(() {
        selectedDate = date;
      });
    }
  }

  /// SAVE BILL
  Future<void> saveBill() async {

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection("user")
        .doc(uid)
        .collection("bills")
        .add({

      "bill_name": billController.text,
      "amount": double.parse(amountController.text),
      "status": status,
      "note": noteController.text,
      "reminder": reminder,
      "date": Timestamp.fromDate(selectedDate),

    });
  }

  /// STATUS POPUP
  void openStatusPopup(){

    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 350, 20, 0),
      items: [

        PopupMenuItem(
          child: const Text("ยังไม่ชำระ"),
          onTap: (){
            setState(() {
              status = "ยังไม่ชำระ";
            });
          },
        ),

        PopupMenuItem(
          child: const Text("ชำระแล้ว"),
          onTap: (){
            setState(() {
              status = "ชำระแล้ว";
            });
          },
        ),

      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Add Bill"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// BILL NAME
            const Text("Bill Name"),

            const SizedBox(height:8),

            TextField(
              controller: billController,
              decoration: InputDecoration(
                hintText: "Enter Bill Name",
                prefixIcon: const Icon(Icons.receipt_long),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height:20),

            /// DATE
            const Text("Date"),

            const SizedBox(height:8),

            GestureDetector(
              onTap: pickDate,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Text("${selectedDate.toLocal()}".split(' ')[0]),

                    const Icon(Icons.calendar_month)

                  ],
                ),
              ),
            ),

            const SizedBox(height:20),

            /// AMOUNT
            const Text("Amount"),

            const SizedBox(height:8),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter Amount",
                suffixText: "฿",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height:20),

            /// STATUS
            const Text("Status"),

            const SizedBox(height:8),

            GestureDetector(
              onTap: openStatusPopup,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [

                    const Icon(Icons.check_circle_outline),

                    const SizedBox(width:10),

                    Text(status),

                    const Spacer(),

                    const Icon(Icons.arrow_drop_down)

                  ],
                ),
              ),
            ),

            const SizedBox(height:20),

            /// NOTE
            const Text("Note"),

            const SizedBox(height:8),

            TextField(
              controller: noteController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Additional notes",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height:20),

            /// REMINDER
            Row(
              children: [

                const Icon(Icons.notifications_none),

                const SizedBox(width:10),

                const Text("Reminder"),

                const Spacer(),

                Switch(
                  value: reminder,
                  activeColor: const Color(0xff8B3A5A),
                  onChanged: (v){
                    setState(() {
                      reminder = v;
                    });
                  },
                )

              ],
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

                  if(amountController.text.isEmpty) return;

                  await saveBill();

                  Navigator.pop(context);

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
            )

          ],
        ),
      ),
    );
  }
}