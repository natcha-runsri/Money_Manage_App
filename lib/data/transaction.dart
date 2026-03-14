import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {

  String selectedCategory = "";
  DateTime? selectedDate;
  String viewType = "weekly";
  DateTime rangeStart = DateTime.now();
DateTime rangeEnd = DateTime.now();

void updateRange() {

  DateTime base = selectedDate ?? DateTime.now();

  if (viewType == "daily") {

    rangeStart = DateTime(base.year, base.month, base.day);
    rangeEnd = rangeStart.add(const Duration(days: 1));

  }

  if (viewType == "weekly") {

    int weekday = base.weekday;

    rangeStart = base.subtract(Duration(days: weekday - 1));
    rangeStart = DateTime(rangeStart.year, rangeStart.month, rangeStart.day);

    rangeEnd = rangeStart.add(const Duration(days: 7));
  }

  if (viewType == "monthly") {

    rangeStart = DateTime(base.year, base.month, 1);

    rangeEnd = DateTime(base.year, base.month + 1, 1);
  }
}

  final uid = FirebaseAuth.instance.currentUser!.uid;

Future<List<QueryDocumentSnapshot>> loadTransactions() async {

  updateRange();

  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection("user")
      .doc(uid)
      .collection("transactions")
      .where("date", isGreaterThanOrEqualTo: rangeStart)
      .where("date", isLessThan: rangeEnd)
      .orderBy("date", descending: true)
      .get();

  List<QueryDocumentSnapshot> docs = snapshot.docs;

  if (selectedCategory.isNotEmpty) {
    docs = docs.where((d) => d["category"] == selectedCategory).toList();
  }

  return docs;
}

  double income = 0;
  double expense = 0;

  Future calculateSummary(List<QueryDocumentSnapshot> docs) async {

    income = 0;
    expense = 0;

    for (var doc in docs) {

      double amount = (doc["amount"] as num).toDouble();

      if (doc["type"] == "income") {
        income += amount;
      } else {
        expense += amount;
      }

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xffF6F3F5),

      appBar: AppBar(
        title: const Text("Transaction"),
        centerTitle: true,
      ),

      body: FutureBuilder(

        future: loadTransactions(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<QueryDocumentSnapshot> docs = snapshot.data!;
          calculateSummary(docs);

          Map<String,List<QueryDocumentSnapshot>> grouped = {};

          for (var doc in docs) {

            DateTime d = (doc["date"] as Timestamp).toDate();

            String key = "${d.day}-${d.month}-${d.year}";

            if (!grouped.containsKey(key)) {
              grouped[key] = [];
            }

            grouped[key]!.add(doc);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [

              /// FILTER BUTTON
              Row(
                children: [

                  _filterButton("Daily"),
                  _filterButton("Weekly"),
                  _filterButton("Monthly"),

                ],
              ),

              const SizedBox(height: 12),

              /// SEARCH DATE
              TextField(
                readOnly: true,
                decoration: InputDecoration(
                  hintText: "Search by date",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: const Icon(Icons.calendar_today),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),

                onTap: () async {

                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2030),
                  );

                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }

                },
              ),

              const SizedBox(height: 20),

              /// SUMMARY BOX
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                  
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
  rangeLabel(),
  style: const TextStyle(fontWeight: FontWeight.bold),
),
                    Text(
                      "Summary",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("฿ ${income.toStringAsFixed(0)}"),
                        Text(
                          "-${expense.toStringAsFixed(0)}",
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Balance"),

                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),

                          decoration: BoxDecoration(
                            color: const Color(0xff8B3A5A),
                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: Text(
                            "฿ ${(income-expense).toStringAsFixed(0)}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        )
                      ],
                    )

                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// CATEGORY FILTER
              const Text(
                "Category",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [

                    _categoryButton("Travel", Icons.flight),
                    _categoryButton("Home", Icons.home),
                    _categoryButton("Food", Icons.restaurant),
                    _categoryButton("Health", Icons.favorite),
                    _categoryButton("Bills", Icons.receipt),
                    _categoryButton("Pet", Icons.pets),
                    _categoryButton("Shopping", Icons.shopping_bag),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// TRANSACTION LIST
              ...grouped.entries.map((entry) {

                DateTime d = (entry.value.first["date"] as Timestamp).toDate();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      "${d.day} ${_monthName(d.month)} ${d.year}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    ...entry.value.map((doc){

                      double amount = (doc["amount"] as num).toDouble();
                      bool isIncome = doc["type"] == "income";

                      return ListTile(

                        leading: CircleAvatar(
                          backgroundColor: Colors.red,
                          child: Icon(
                            Icons.category,
                            color: Colors.white,
                          ),
                        ),

                        title: Text(doc["category"]),

                        subtitle: Text(doc["category"]),

                        trailing: Text(
                          "${isIncome ? "+" : "-"}${amount.toStringAsFixed(0)}",
                          style: TextStyle(
                            color: isIncome ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      );

                    })

                  ],
                );

              }).toList()

            ],
          );

        },

      ),
    );
  }

  Widget _filterButton(String text) {

    bool active = viewType.toLowerCase() == text.toLowerCase();

    return Expanded(
      child: GestureDetector(

       onTap: () {

  setState(() {

    viewType = text.toLowerCase();

  });

},

        child: Container(

          padding: const EdgeInsets.symmetric(vertical: 10),

          decoration: BoxDecoration(
            color: active ? const Color(0xff8B3A5A) : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),

          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: active ? Colors.white : Colors.black,
              ),
            ),
          ),

        ),
      ),
    );
  }

  Widget _categoryButton(String cat, IconData icon) {

    bool active = selectedCategory == cat;

    return GestureDetector(

      onTap: (){
        setState(() {
          selectedCategory = active ? "" : cat;
        });
      },

      child: Container(
        margin: const EdgeInsets.only(right: 10),

        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: active ? const Color(0xff8B3A5A) : Colors.white,
          shape: BoxShape.circle,
        ),

        child: Icon(
          icon,
          color: active ? Colors.white : Colors.black,
        ),
      ),

    );
  }

  String _monthName(int month) {

    const months = [
      "",
      "January","February","March","April","May","June",
      "July","August","September","October","November","December"
    ];

    return months[month];
  }
  String rangeLabel() {

  if (viewType == "daily") {

    DateTime d = rangeStart;

    return "${d.day} ${_monthName(d.month)} ${d.year}";
  }

  if (viewType == "weekly") {

    DateTime end = rangeEnd.subtract(const Duration(days: 1));

    return "${rangeStart.day} ${_monthName(rangeStart.month)} - ${end.day} ${_monthName(end.month)} ${end.year}";
  }

  if (viewType == "monthly") {

    DateTime end = rangeEnd.subtract(const Duration(days: 1));

    return "${rangeStart.day} ${_monthName(rangeStart.month)} - ${end.day} ${_monthName(end.month)} ${end.year}";
  }

  return "";
}

}
