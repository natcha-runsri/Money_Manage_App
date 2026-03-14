import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'setting.dart';
import '../notification.dart';
import 'analysis.dart';
import 'pocket.dart';
import '../add_data/add_transaction.dart';
import '../add_data/add_budget.dart';
import '../add_data/add_bill.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data_detail/bill_detail.dart';
import '../data_detail/profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  bool showMenu = false;

  final List<Widget> pages = const [
    MainPage(),
    PocketPage(),
    AnalysisPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F3F5),

      /// FAB
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: const Color.fromARGB(255, 126, 44, 43),
        child: Icon(
          showMenu ? Icons.close : Icons.add,
          color: Colors.white,
          size: 40,
        ),
        onPressed: () {
          setState(() {
            showMenu = !showMenu;
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      /// Bottom Navigation
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                Icons.menu_book,
                "Main",
                isActive: currentIndex == 0,
                onTap: () {
                  setState(() => currentIndex = 0);
                },
              ),

              _NavItem(
                Icons.business_center,
                "Pocket",
                isActive: currentIndex == 1,
                onTap: () {
                  setState(() => currentIndex = 1);
                },
              ),

              _NavItem(
                Icons.bar_chart,
                "Analysis",
                isActive: currentIndex == 2,
                onTap: () {
                  setState(() => currentIndex = 2);
                },
              ),

              _NavItem(
                Icons.format_list_bulleted,
                "Setting",
                isActive: currentIndex == 3,
                onTap: () {
                  setState(() => currentIndex = 3);
                },
              ),
            ],
          ),
        ),
      ),

      /// Body
      body: Stack(
        children: [
          /// Page switch
          IndexedStack(index: currentIndex, children: pages),

          /// Floating Menu
          if (showMenu)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  children: [
                    /// เพิ่มรายรับ / รายจ่าย
                    _floatingItem(
                      "เพิ่มรายรับ / รายจ่าย",
                      Icons.attach_money,
                      () {
                        setState(() {
                          showMenu = false;
                        });

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddTransactionPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    /// เพิ่มเป้าหมาย
                    _floatingItem("เพิ่มเป้าหมาย / งบประมาณ", Icons.flag, () {
                      setState(() {
                        showMenu = false;
                      });

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddGoalPage()),
                      );
                    }),

                    const SizedBox(height: 10),

                    /// เพิ่มกำหนดการชำระ
                    _floatingItem(
                      "เพิ่มกำหนดการชำระ",
                      Icons.calendar_month,
                      () {
                        setState(() {
                          showMenu = false;
                        });

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddSchedulePage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// ================= MAIN PAGE =================

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String searchText = "";
  String username = "";
  String accountName = "";
  double balance = 0;
  Set<DateTime> incomeDays = {};
  Set<DateTime> expenseDays = {};

  Map<DateTime, List<Map<String, dynamic>>> bills = {};
  List<Map<String, dynamic>> allItems = [];

  Future<void> loadAllData(DateTime selectedDay) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    DateTime start = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
    );
    DateTime end = start.add(const Duration(days: 1));

    List<Map<String, dynamic>> items = [];

    /// transactions
    final transSnap =
        await FirebaseFirestore.instance
            .collection("user")
            .doc(uid)
            .collection("transactions")
            .where("date", isGreaterThanOrEqualTo: start)
            .where("date", isLessThan: end)
            .get();

    for (var doc in transSnap.docs) {
      var data = doc.data();
      data["category"] = "transaction";
      items.add(data);
    }

    /// budgets
    final budgetSnap =
        await FirebaseFirestore.instance
            .collection("user")
            .doc(uid)
            .collection("budgets")
            .get();

    for (var doc in budgetSnap.docs) {
      var data = doc.data();
      data["category"] = "budget";
      items.add(data);
    }

    /// bills
    final billSnap =
        await FirebaseFirestore.instance
            .collection("user")
            .doc(uid)
            .collection("bills")
            .where("date", isGreaterThanOrEqualTo: start)
            .where("date", isLessThan: end)
            .get();

    for (var doc in billSnap.docs) {
      var data = doc.data();
      data["category"] = "bill";
      items.add(data);
    }

    setState(() {
      allItems = items;
    });
  }

  Future<void> loadBills() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore.instance
        .collection("user")
        .doc(uid)
        .collection("bills")
        .snapshots()
        .listen((snapshot) {
          Map<DateTime, List<Map<String, dynamic>>> data = {};

          for (var doc in snapshot.docs) {
            final bill = doc.data();

            Timestamp ts = bill["date"];
            DateTime date = DateTime(
              ts.toDate().year,
              ts.toDate().month,
              ts.toDate().day,
            );

            if (!data.containsKey(date)) {
              data[date] = [];
            }

            data[date]!.add(bill);
          }

          setState(() {
            bills = data;
          });
        });
  }

  Future<void> loadTransactionMarkers() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final snapshot =
        await FirebaseFirestore.instance
            .collection("user")
            .doc(uid)
            .collection("transactions")
            .get();

    Set<DateTime> income = {};
    Set<DateTime> expense = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();

      Timestamp ts = data["date"];
      DateTime d = ts.toDate();

      DateTime key = DateTime(d.year, d.month, d.day);

      if (data["type"] == "income") {
        income.add(key);
      } else {
        expense.add(key);
      }
    }

    setState(() {
      incomeDays = income;
      expenseDays = expense;
    });
  }

  final Map<DateTime, List<Map<String, dynamic>>> transactions = {
    DateTime(2026, 3, 19): [
      {"title": "ค่าห้อง", "amount": -4500, "paid": false},
    ],
  };

  List<Map<String, dynamic>> getTransactions(DateTime day) {
    return transactions[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
    loadBills();
    checkBills();
    loadTransactionMarkers();
  }

  @override
  Widget build(BuildContext context) {
    final rawList = _selectedDay == null ? [] : getTransactions(_selectedDay!);

    final list =
        rawList.where((item) {
          return item["title"].toLowerCase().contains(searchText.toLowerCase());
        }).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            /// HEADER
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      );
                    },
                    child: const CircleAvatar(
                      radius: 26,
                      backgroundImage: AssetImage("images/avatar.png"),
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// USER INFO
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// username
                        Text(
                          username.isEmpty ? "UserName" : username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        /// account name
                        Text(
                          accountName.isEmpty ? "Account Name" : accountName,
                          style: const TextStyle(fontSize: 13),
                        ),

                        /// balance realtime
                        StreamBuilder<QuerySnapshot>(
                          stream:
                              FirebaseFirestore.instance
                                  .collection("user")
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection("transactions")
                                  .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Text("ยอดเงินคงเหลือ 0.00");
                            }

                            double income = 0;
                            double expense = 0;

                            for (var doc in snapshot.data!.docs) {
                              final data = doc.data() as Map<String, dynamic>;

                              double amount =
                                  (data["amount"] as num).toDouble();

                              if (data["type"] == "income") {
                                income += amount;
                              } else {
                                expense += amount;
                              }
                            }

                            double balance = income - expense;

                            return Text(
                              "ยอดเงินคงเหลือ ${balance.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: Color(0xff8B3A5A),
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  /// notification
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            /// SEARCH
            TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _focusedDay,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );

                    if (picked != null) {
                      setState(() {
                        _selectedDay = picked;
                        _focusedDay = picked;
                      });
                    }
                  },
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// CALENDAR
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection("user")
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection("bills")
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                /// เก็บวันที่ที่มีบิล
                Set<DateTime> billDays = {};

                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;

                  Timestamp ts = data["date"];
                  DateTime d = ts.toDate();

                  billDays.add(DateTime(d.year, d.month, d.day));
                }

                return TableCalendar(
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2030),
                  focusedDay: _focusedDay,

                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                    });

                    loadAllData(selected);
                  },

                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      DateTime key = DateTime(day.year, day.month, day.day);

                      List<Widget> markers = [];

                      if (incomeDays.contains(key)) {
                        markers.add(
                          const Icon(
                            Icons.arrow_upward,
                            size: 10,
                            color: Colors.green,
                          ),
                        );
                      }

                      if (expenseDays.contains(key)) {
                        markers.add(
                          const Icon(
                            Icons.arrow_downward,
                            size: 10,
                            color: Colors.red,
                          ),
                        );
                      }

                      if (billDays.contains(key)) {
                        markers.add(
                          const Icon(
                            Icons.star,
                            size: 10,
                            color: Colors.orange,
                          ),
                        );
                      }

                      if (markers.isEmpty) return null;

                      return Positioned(
                        bottom: 1,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: markers,
                        ),
                      );
                    },
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.pink.shade200,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: Color(0xff8B3A5A),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            /// LIST
            Expanded(
              child:
                  _selectedDay == null
                      ? const Center(child: Text("เลือกวันที่"))
                      : allItems.isEmpty
                      ? const Center(child: Text("ไม่มีข้อมูล"))
                      : ListView.builder(
                        itemCount: allItems.length,
                        itemBuilder: (context, index) {
                          final item = allItems[index];

                          IconData icon = Icons.attach_money;
                          Color color = Colors.green;
                          String title = "";
                          String subtitle = "";

                          if (item["category"] == "transaction") {
                            icon =
                                item["type"] == "income"
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward;

                            color =
                                item["type"] == "income"
                                    ? Colors.green
                                    : Colors.red;

                            title = item["category_name"] ?? "Transaction";
                            subtitle = "${item["amount"]} บาท";
                          }

                          if (item["category"] == "bill") {
                            icon = Icons.receipt;
                            color = Colors.orange;

                            title = item["bill_name"];
                            subtitle = item["status"];
                          }

                          if (item["category"] == "budget") {
                            icon = Icons.flag;
                            color = Colors.blue;

                            title = item["name"];
                            subtitle = "Budget";
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: color,
                                  child: Icon(icon, color: Colors.white),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(subtitle),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final userDoc =
        await FirebaseFirestore.instance.collection("user").doc(uid).get();

    if (userDoc.exists) {
      setState(() {
        username = userDoc.data()?["username"] ?? "";
        accountName = userDoc.data()?["accountName"] ?? "";
      });
    }
  }

  Future<void> checkBills() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore.instance
        .collection("user")
        .doc(uid)
        .collection("bills")
        .snapshots()
        .listen((snapshot) {
          DateTime now = DateTime.now();

          for (var doc in snapshot.docs) {
            final data = doc.data();

            Timestamp ts = data["date"];
            DateTime billDate = ts.toDate();

            int diff = billDate.difference(now).inDays;

            if (diff <= 1 && data["status"] != "ชำระแล้ว") {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "🔔 บิล ${data["bill_name"]} จะครบกำหนดพรุ่งนี้",
                  ),
                ),
              );
            }
          }
        });
  }
}

String _monthName(int month) {
  const months = [
    "",
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  return months[month];
}

/// ================= NAV ITEM =================

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isActive;

  const _NavItem(this.icon, this.label, {this.onTap, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    Color activeColor = const Color.fromARGB(255, 127, 42, 83);
    Color inactiveColor = const Color.fromARGB(255, 219, 182, 206);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? activeColor : inactiveColor, size: 30),

          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isActive ? activeColor : inactiveColor,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= FLOATING ITEM =================

Widget _floatingItem(String text, IconData icon, VoidCallback onPressed) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 30, 58, 138),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ],
      ),
    ),
  );
}
