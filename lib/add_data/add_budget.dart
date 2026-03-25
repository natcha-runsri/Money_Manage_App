import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({super.key});

  @override
  State<AddGoalPage> createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {

  final nameController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  bool reminder = false;

  String selectedCategory = "Food";

  List<Map<String,dynamic>> categories = [
    {"name":"Travel","icon":Icons.flight, "color": Color(0xffFF6B6B)},
    {"name":"Home","icon":Icons.home, "color": Color(0xff4ECDC4)},
    {"name":"Bills","icon":Icons.receipt, "color": Color(0xff45B7D1)},
    {"name":"Food","icon":Icons.restaurant, "color": Color(0xff96CEB4)},
    {"name":"Shopping","icon":Icons.shopping_bag, "color": Color(0xffFFEAA7)},
    {"name":"Other","icon":Icons.category, "color": Color(0xffDDA0DD)},
  ];

  /// SAVE BUDGET
  Future<void> saveBudget() async {

    final uid = FirebaseAuth.instance.currentUser!.uid;
    DateTime selectedDate = DateTime.now();
    double amount =
        double.parse(amountController.text.replaceAll(",", ""));

    await FirebaseFirestore.instance
        .collection("user")
        .doc(uid)
        .collection("budgets")
        .add({
      "name": nameController.text,
      "category": selectedCategory,
      "amount": amount,
      "start_date": Timestamp.fromDate(startDate),
      "end_date": Timestamp.fromDate(endDate),
      "note": noteController.text,
      "reminder": reminder,
      "created_at": Timestamp.now(),
      "used": 0,
      "status": "active",
      "alert": 0.8,
    });

    Navigator.pop(context);
  }

  /// DATE PICKER
  Future<void> pickDate(bool isStart) async {

    DateTime? date = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate : endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if(date != null){
      setState(() {

        if(isStart){
          startDate = date;
        }else{
          endDate = date;
        }

      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Add Budget"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// BUDGET NAME
            const Text("Budget Name"),
            const SizedBox(height:8),

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "Enter Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height:20),

            /// CATEGORY
            const Text("Category"),
            const SizedBox(height:10),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat){

                  bool selected = selectedCategory == cat["name"];

                  return GestureDetector(
                    onTap: (){
                      setState(() {
                        selectedCategory = cat["name"];
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right:10),
                      child: CircleAvatar(
                        backgroundColor:
                        selected ? cat["color"] : Colors.grey.shade300,
                        child: Icon(
                          cat["icon"],
                          color: selected ? Colors.white : Colors.black54,
                        ),
                      ),
                    ),
                  );

                }).toList(),
              ),
            ),

            const SizedBox(height:20),

            /// START DATE
            const Text("Start Date"),
            const SizedBox(height:8),

            GestureDetector(
              onTap: ()=>pickDate(true),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${startDate.toLocal()}".split(' ')[0]),
                    const Icon(Icons.calendar_month)
                  ],
                ),
              ),
            ),

            const SizedBox(height:20),

            /// END DATE
            const Text("End Date"),
            const SizedBox(height:8),

            GestureDetector(
              onTap: ()=>pickDate(false),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${endDate.toLocal()}".split(' ')[0]),
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
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height:20),

            /// NOTE
            const Text("Note"),
            const SizedBox(height:8),

            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Additional notes",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
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
                  activeColor: const Color(0xff7F2A53),
                  onChanged: (val){
                    setState(() {
                      reminder = val;
                    });
                  },
                )
              ],
            ),

            const Spacer(),

            /// SAVE BUTTON
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

                  await saveBudget();

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