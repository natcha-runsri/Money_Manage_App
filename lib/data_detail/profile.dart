import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfileState();
}

class _ProfileState extends State<ProfilePage> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final accountController = TextEditingController();

  final user = FirebaseAuth.instance.currentUser;

  bool isEdit = false;
  String avatarText = "";

  DateTime? selectedDate; // 🔥 birthday

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  /// 🔥 โหลดข้อมูล
  Future<void> loadUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection("user")
        .doc(user!.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;

      usernameController.text = data["username"] ?? "";
      emailController.text = data["email"] ?? "";
      accountController.text = data["accountName"] ?? "";

      if (data["date"] != null) {
        selectedDate = DateTime.parse(data["date"]);
      }

      avatarText = (data["username"] ?? "U")[0].toUpperCase();

      setState(() {});
    }
  }

  /// 🔥 UPDATE
  Future<void> updateProfile() async {
    await FirebaseFirestore.instance
        .collection("user")
        .doc(user!.uid)
        .set({
      "username": usernameController.text,
      "email": emailController.text,
      "accountName": accountController.text,
      "date": selectedDate?.toIso8601String(),
    }, SetOptions(merge: true));

    setState(() {
      isEdit = false;
      avatarText = usernameController.text.isNotEmpty
          ? usernameController.text[0].toUpperCase()
          : "U";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Update Success")),
    );
  }

  /// 🔥 DELETE
  Future<void> deleteAccount() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("คุณต้องการลบบัญชีใช่หรือไม่"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              await FirebaseFirestore.instance
                  .collection("user")
                  .doc(user!.uid)
                  .delete();

              await user!.delete();
            },
            child: const Text("Delete",
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// 🔥 TEXTFIELD
  Widget textField(String title, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        enabled: isEdit,
        decoration: InputDecoration(
          labelText: title,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  /// 🔥 BIRTHDAY PICKER
  Widget birthdayField() {
    return GestureDetector(
      onTap: isEdit
          ? () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime(2000),
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
              );

              if (picked != null) {
                setState(() {
                  selectedDate = picked;
                });
              }
            }
          : null,
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate == null
                  ? "Birthday"
                  : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
            ),
            const Icon(Icons.calendar_month),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F3F5),

      appBar: AppBar(
        title: const Text("Your Profile"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [

            const SizedBox(height: 30),

            /// 🔥 AVATAR
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xff8B3A5A),
              child: Text(
                avatarText,
                style: const TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            textField("Username", usernameController),
            textField("Email", emailController),
            textField("Account Name", accountController),

            birthdayField(), // 🔥 ใช้แทน Join Date

            const SizedBox(height: 20),

            /// 🔥 SAVE BUTTON (modern)
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  if (isEdit) {
                    updateProfile();
                  } else {
                    setState(() => isEdit = true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff3F5576),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  isEdit ? "Save" : "Edit Profile",
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// 🔥 DELETE BUTTON (clean)
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                onPressed: deleteAccount,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Delete Account",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}