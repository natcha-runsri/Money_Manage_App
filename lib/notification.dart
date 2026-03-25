import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F3F5),

      appBar: AppBar(
        backgroundColor: Colors.purple[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Notification",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.black),
            onPressed: () async {
              final uid = FirebaseAuth.instance.currentUser!.uid;

              final snapshot =
                  await FirebaseFirestore.instance
                      .collection("user")
                      .doc(uid)
                      .collection("notifications")
                      .get();

              for (var doc in snapshot.docs) {
                await doc.reference.update({"isRead": true});
              }
            },
          ),

          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.black),
            onPressed: () async {
              final uid = FirebaseAuth.instance.currentUser!.uid;

              final snapshot =
                  await FirebaseFirestore.instance
                      .collection("user")
                      .doc(uid)
                      .collection("notifications")
                      .get();

              for (var doc in snapshot.docs) {
                await doc.reference.delete();
              }
            },
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection("user")
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection("notifications")
                .orderBy("created_at", descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("ไม่มีแจ้งเตือน"));
          }

          List today = [];
          List earlier = [];

          for (var doc in docs) {
            DateTime d = (doc["created_at"] as Timestamp).toDate();

            if (d.day == DateTime.now().day &&
                d.month == DateTime.now().month &&
                d.year == DateTime.now().year) {
              today.add(doc);
            } else {
              earlier.add(doc);
            }
          }

          return ListView(
            children: [
              if (today.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "Today",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ...today.map((doc) => buildItem(doc)),
              ],
              if (earlier.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "Earlier",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ...earlier.map((doc) => buildItem(doc)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget notificationItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffF6F3F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          Text(time, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget buildItem(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final type = data["type"] ?? "other";
    final isRead = data["isRead"] ?? false;

    DateTime time = (data["created_at"] as Timestamp).toDate();

    return Dismissible(
      key: Key(doc.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) async {
        await doc.reference.delete();
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),

      child: GestureDetector(
        onTap: () async {
          await doc.reference.update({"isRead": true}); // ✅ กดแล้วอ่าน
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isRead ? const Color.fromARGB(255, 255, 235, 248) : Colors.purple[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: getColor(type).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(getIcon(type), color: getColor(type)),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data["title"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data["message"],
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              Text(
                timeAgo(time), // ⏰ ใช้ตรงนี้
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppNotification {
  final String title;
  final String message;
  final DateTime time;
  final String type;

  AppNotification({
    required this.title,
    required this.message,
    required this.time,
    required this.type,
  });
}

String timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);

  if (diff.inSeconds < 60) return "just now";
  if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
  if (diff.inHours < 24) return "${diff.inHours}h ago";
  if (diff.inDays == 1) return "1d ago";
  return "${diff.inDays}d ago";
}

IconData getIcon(String type) {
  switch (type) {
    case "bill":
      return Icons.receipt_long;
    case "budget":
      return Icons.warning;
    case "transaction":
      return Icons.swap_vert;
    default:
      return Icons.notifications;
  }
}

Color getColor(String type) {
  switch (type) {
    case "bill":
      return Colors.orange;
    case "budget":
      return Colors.red;
    case "transaction":
      return Colors.blue;
    default:
      return Colors.grey;
  }
}
