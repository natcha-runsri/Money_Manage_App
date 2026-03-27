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
import '../data_detail/transaction_detail.dart';
import '../data_detail/budget_detail.dart';

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
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: const Color.fromARGB(255, 126, 44, 43),
        child: Icon(
          showMenu ? Icons.close : Icons.add,
          color: Colors.white,
          size: 40,
        ),
        onPressed: () {
          if (!mounted) return;
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
                  if (!mounted) return;
                  setState(() => currentIndex = 0);
                },
              ),
              _NavItem(
                Icons.business_center,
                "Pocket",
                isActive: currentIndex == 1,
                onTap: () {
                  if (!mounted) return;
                  setState(() => currentIndex = 1);
                },
              ),

              _NavItem(
                Icons.bar_chart,
                "Analysis",
                isActive: currentIndex == 2,
                onTap: () {
                  if (!mounted) return;
                  setState(() => currentIndex = 2);
                },
              ),

              _NavItem(
                Icons.format_list_bulleted,
                "Setting",
                isActive: currentIndex == 3,
                onTap: () {
                  if (!mounted) return;
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
                      () async {
                        if (!mounted) return;
                        setState(() {
                          showMenu = false;
                        });

                        await Navigator.push(
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
                        if (!mounted) return;
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
  int notificationCount = 0;

  IconData getIconByCategory(String? category) {
    switch (category) {
      case "Food":
        return Icons.restaurant;
      case "Travel":
        return Icons.flight;
      case "Home":
        return Icons.home;
      case "Shopping":
        return Icons.shopping_cart;
      case "Health":
        return Icons.favorite;
      default:
        return Icons.attach_money;
    }
  }

  Map<DateTime, List<Map<String, dynamic>>> bills = {};
  List<Map<String, dynamic>> allItems = [];

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
          if (!mounted) return;
          setState(() {
            bills = data;
          });
        });
  }

  void loadTransactionMarkers() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore.instance
        .collection("user")
        .doc(uid)
        .collection("transactions")
        .snapshots()
        .listen((snapshot) {
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
          if (!mounted) return;
          setState(() {
            incomeDays = income;
            expenseDays = expense;
          });
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
    DateTime today = DateTime.now();
    _selectedDay = today;
    _focusedDay = today;

    loadUserData();
    loadBills();
    checkBills();
    loadTransactionMarkers();
  }

  @override
  Widget build(BuildContext context) {
    final day = _selectedDay ?? DateTime.now();

    DateTime start = DateTime(day.year, day.month, day.day);
    DateTime end = start.add(const Duration(days: 1));

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
                  /// USER INFO
                  Expanded(
                    child: StreamBuilder<DocumentSnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection("user")
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return const Text("Loading...");
                        }

                        final data =
                            snapshot.data!.data() as Map<String, dynamic>;

                        String username = data["username"] ?? "";
                        String accountName = data["accountName"] ?? "";

                        return Column(
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

                            const SizedBox(height: 4),

                            /// account name
                            Text(
                              accountName.isEmpty
                                  ? "Account Name"
                                  : accountName,
                            ),

                            const SizedBox(height: 6),

                            /// 🔥 balance realtime
                            StreamBuilder<QuerySnapshot>(
                              stream:
                                  FirebaseFirestore.instance
                                      .collection("user")
                                      .doc(
                                        FirebaseAuth.instance.currentUser!.uid,
                                      )
                                      .collection("transactions")
                                      .snapshots(),
                              builder: (context, txSnap) {
                                if (!txSnap.hasData) {
                                  return const Text("ยอดเงินคงเหลือ 0.00");
                                }

                                double income = 0;
                                double expense = 0;

                                for (var doc in txSnap.data!.docs) {
                                  final tx = doc.data() as Map<String, dynamic>;

                                  double amount =
                                      (tx["amount"] ?? 0).toDouble();

                                  if (tx["type"] == "income") {
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
                        );
                      },
                    ),
                  ),

                  StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection("user")
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .collection("notifications")
                            .where("isRead", isEqualTo: false)
                            .snapshots(),
                    builder: (context, snapshot) {
                      int count = snapshot.data?.docs.length ?? 0;

                      return Stack(
                        children: [
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

                          if (count > 0)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: IgnorePointer(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    count > 9 ? "9+" : count.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
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
                if (!mounted) return;
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
                      if (!mounted) return;
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
                    if (!mounted) return;

                    setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                    });
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
            Expanded(
              child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance
                        .collection("user")
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection("transactions")
                        .where("date", isGreaterThanOrEqualTo: start)
                        .where("date", isLessThan: end)
                        .snapshots(),
                builder: (context, transSnap) {
                  if (!transSnap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final uid = FirebaseAuth.instance.currentUser!.uid;
                  return StreamBuilder(
                    stream:
                        FirebaseFirestore.instance
                            .collection("user")
                            .doc(uid)
                            .collection("bills")
                            .where("date", isGreaterThanOrEqualTo: start)
                            .where("date", isLessThan: end)
                            .snapshots(),
                    builder: (context, billSnap) {
                      if (!billSnap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return StreamBuilder(
                        stream:
                            FirebaseFirestore.instance
                                .collection("user")
                                .doc(uid)
                                .collection("budgets")
                                .snapshots(),
                        builder: (context, budgetSnap) {
                          if (!budgetSnap.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final transDocs = transSnap.data!.docs;
                          final billDocs = billSnap.data!.docs;
                          final budgetDocs = budgetSnap.data!.docs;

                          List<Map<String, dynamic>> items = [];

                          /// TRANSACTION
                          for (var doc in transDocs) {
                            var data = doc.data() as Map<String, dynamic>;
                            data["itemType"] = "transaction";
                            data["docId"] = doc.id;
                            items.add(data);
                          }

                          /// BILL
                          for (var doc in billDocs) {
                            var data = doc.data() as Map<String, dynamic>;
                            data["type"] = "bill";
                            data["docId"] = doc.id;
                            items.add(data);
                          }

                          /// BUDGET
                          for (var doc in budgetDocs) {
                            var data = doc.data() as Map<String, dynamic>;

                            if (data["start_date"] != null &&
                                data["end_date"] != null) {
                              DateTime startDate =
                                  (data["start_date"] as Timestamp).toDate();

                              DateTime endDate =
                                  (data["end_date"] as Timestamp).toDate();

                              DateTime start = DateTime(
                                startDate.year,
                                startDate.month,
                                startDate.day,
                              );

                              DateTime end = DateTime(
                                endDate.year,
                                endDate.month,
                                endDate.day,
                              );

                              DateTime selected = DateTime(
                                day.year,
                                day.month,
                                day.day,
                              );

                              /// เช็คช่วงเวลา
                              if (!selected.isBefore(start) &&
                                  !selected.isAfter(end)) {
                                data["type"] = "budget";
                                data["docId"] = doc.id;
                                items.add(data);
                              }
                            }
                          }
                          if (items.isEmpty) {
                            return const Center(
                              child: Text("ไม่มีข้อมูลวันนี้"),
                            );
                          }

                          return ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];

                              IconData icon;
                              Color color = Colors.grey;
                              String title;
                              String subtitle;

                              if (item["itemType"] == "transaction") {
                                icon = getIconByCategory(item["category"]);

                                color =
                                    (item["category"] == "income"
                                        ? Colors.green
                                        : Colors.red);

                                title = item["name"];
                                subtitle = "${item["amount"]} บาท";
                              } else if (item["type"] == "bill") {
                                icon = Icons.receipt;
                                color = Colors.orange;
                                title = item["bill_name"] ?? "-";
                                subtitle = item["status"] ?? "-";
                              } else {
                                icon = Icons.flag;
                                color = Colors.blue;
                                title = item["name"];
                                subtitle = "Budget";
                              }

                              return InkWell(
                                onTap: () {
                                  if (item["itemType"] == "transaction") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => TransactionDetailPage(
                                              docId: item["docId"],
                                              data: item,
                                            ),
                                      ),
                                    );
                                  } else if (item["type"] == "bill") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => BillDetailPage(
                                              docId: item["docId"],
                                              data: item,
                                            ),
                                      ),
                                    );
                                  } else if (item["type"] == "budget") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => BudgetDetailPage(
                                              docId: item["docId"],
                                              data: item,
                                            ),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: color.withOpacity(0.2),
                                        child: Icon(icon, color: color),
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
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
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
      if (!mounted) return;
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
        .listen((snapshot) async {
          // ✅ ใส่ async ตรงนี้

          int count = 0;
          DateTime now = DateTime.now();

          for (var doc in snapshot.docs) {
            final data = doc.data();

            Timestamp ts = data["date"];
            DateTime billDate = ts.toDate();

            int diff = billDate.difference(now).inDays;

            if (diff <= 1 &&
                data["status"] != "ชำระแล้ว" &&
                data["notified"] != true) {
              count++;
              // ✅ สร้าง notification
              await FirebaseFirestore.instance
                  .collection("user")
                  .doc(uid)
                  .collection("notifications")
                  .add({
                    "title": "บิลใกล้ครบกำหนด",
                    "message": "บิล ${data["bill_name"]} จะครบกำหนด",
                    "created_at": Timestamp.now(),
                    "isRead": false,
                  });

              // ✅ mark ว่าแจ้งแล้ว
              await doc.reference.update({"notified": true});
            }
          }
          if (!mounted) return;
          setState(() {
            notificationCount = count;
          });
        });
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// String _monthName(int month) {
//   const months = [
//     "",
//     "January",
//     "February",
//     "March",
//     "April",
//     "May",
//     "June",
//     "July",
//     "August",
//     "September",
//     "October",
//     "November",
//     "December",
//   ];

//   return months[month];
// }

/// ================= NAV ITEM =================

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isActive;

  const _NavItem(this.icon, this.label, {this.onTap, this.isActive = false});
  IconData getIcon(String? name) {
    switch (name) {
      case "money":
        return Icons.attach_money;
      case "food":
        return Icons.fastfood;
      case "travel":
        return Icons.directions_car;
      case "shopping":
        return Icons.shopping_cart;
      case "home":
        return Icons.home;
      default:
        return Icons.attach_money;
    }
  }

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
